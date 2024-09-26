local vim = vim
local Job = require('plenary.job')
local M = {}
local cache = {}
local cache_timeout = 900 -- 15 minutes
local notification_queue = {}
local top_lang_count = 5
local activity_count = 5

local function queue_notification(message, level)
    table.insert(notification_queue, { message = message, level = level })
end

local function show_notification(message, level)
    vim.notify(message, level, {
        title = 'GitHub Stats',
        timeout = 5000,
    })
end

local function process_notification_queue()
    vim.schedule(function()
        while #notification_queue > 0 do
            local notification = table.remove(notification_queue, 1)
            show_notification(notification.message, notification.level)
        end
    end)
end

local function async_execute(command, callback)
    Job:new({
        command = 'bash',
        args = { '-c', command },
        on_exit = function(j, return_val)
            local result = table.concat(j:result(), '\n')
            if return_val ~= 0 then
                queue_notification('Error executing command: ' .. command, vim.log.levels.ERROR)
                process_notification_queue()
                return
            end
            callback(result)
        end,
    }):start()
end

local function safe_json_decode(str)
    local success, result = pcall(vim.json.decode, str)
    if success then
        return result
    else
        queue_notification('Failed to parse JSON: ' .. result, vim.log.levels.ERROR)
        return nil
    end
end

local function get_data_with_cache(cache_key, command, callback)
    if cache[cache_key] and os.time() - cache[cache_key].time < cache_timeout then
        callback(cache[cache_key].data)
        return
    end

    async_execute(command, function(result)
        local data = safe_json_decode(result)
        if data then
            cache[cache_key] = { data = data, time = os.time() }
            callback(data)
        end
    end)
end

local function language_to_filetype(language)
    local map = {
        ['C'] = 'c',
        ['C++'] = 'cpp',
        ['Java'] = 'java',
        ['Python'] = 'py',
        ['JavaScript'] = 'js',
        ['TypeScript'] = 'ts',
        ['Ruby'] = 'rb',
        ['Go'] = 'go',
        ['Rust'] = 'rs',
        ['Shell'] = 'sh',
        ['Lua'] = 'lua',
        ['HTML'] = 'html',
        ['CSS'] = 'css',
        ['PHP'] = 'php',
        ['Swift'] = 'swift',
        ['Kotlin'] = 'kt',
        ['Scala'] = 'scala',
        ['Groovy'] = 'groovy',
        ['Perl'] = 'perl',
    }

    return map[language]
end

local function select_emoji(contributionCount)
    if contributionCount == 0 then
        return '⚪️'
    elseif contributionCount <= 10 then
        return '🟡'
    elseif contributionCount <= 20 then
        return '🟠'
    elseif contributionCount <= 30 then
        return '🟢'
    elseif contributionCount <= 40 then
        return '🔵'
    elseif contributionCount <= 50 then
        return '🟣'
    else
        return '🔴'
    end
end

local function get_github_stats(username, callback)
    local command = username == '' and 'gh api user' or 'gh api users/' .. username
    get_data_with_cache('user_' .. username, command, callback)
end

local function get_default_username(callback)
    async_execute('gh api user', function(result)
        local data = safe_json_decode(result)
        if data then
            callback(data.login)
        end
    end)
end

local function get_user_repos(username, callback)
    local function process_username(username)
        local all_repos = {}

        local function fetch_page(page)
            local command = 'gh api users/' .. username .. '/repos?page=' .. page
            get_data_with_cache('repos_' .. username .. '_page_' .. page, command, function(repos)
                if repos and #repos > 0 then
                    for _, repo in ipairs(repos) do
                        table.insert(all_repos, repo)
                    end
                    fetch_page(page + 1)
                else
                    callback(all_repos)
                end
            end)
        end

        fetch_page(1)
    end

    if username == nil or username == '' then
        get_default_username(function(default_username)
            process_username(default_username)
        end)
    else
        process_username(username)
    end
end

local function get_user_events(username, callback)
    local command = 'gh api users/' .. username .. '/events?per_page=100'
    get_data_with_cache('events_' .. username, command, callback)
end

local function get_contribution_data(username, callback)
    local command = 'gh api graphql -f query=\'{user(login: "'
        .. username
        .. '") { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount } } } } } }\''
    get_data_with_cache('contrib_' .. username, command, callback)
end

local function generate_contribution_graph(contrib_data)
    local calendar = contrib_data.data.user.contributionsCollection.contributionCalendar
    local graph_parts = {}
    for _, week in ipairs(calendar.weeks) do
        for _, day in ipairs(week.contributionDays) do
            local emoji = select_emoji(day.contributionCount)
            local padded_count = string.format('%3d  ', day.contributionCount)
            table.insert(graph_parts, emoji .. padded_count)
        end
        table.insert(graph_parts, '\n')
    end
    return table.concat(graph_parts)
end

local function show_stats_window(content)
    local stats_window_buf = nil
    local stats_window_win = nil

    vim.schedule(function()
        if not stats_window_buf or not vim.api.nvim_buf_is_valid(stats_window_buf) then
            stats_window_buf = vim.api.nvim_create_buf(false, true)
        end

        vim.api.nvim_buf_set_lines(stats_window_buf, 0, -1, true, vim.split(content, '\n'))

        if not stats_window_win or not vim.api.nvim_win_is_valid(stats_window_win) then
            local width = math.min(120, vim.o.columns - 4)
            local height = math.min(30, vim.o.lines - 4)
            stats_window_win = vim.api.nvim_open_win(stats_window_buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                col = (vim.o.columns - width) / 2,
                row = (vim.o.lines - height) / 2,
                style = 'minimal',
                border = 'rounded',
            })

            vim.api.nvim_win_set_option(stats_window_win, 'wrap', true)
            vim.api.nvim_win_set_option(stats_window_win, 'cursorline', true)
            vim.api.nvim_buf_set_keymap(stats_window_buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
        else
            vim.api.nvim_win_set_buf(stats_window_win, stats_window_buf)
        end
    end)
end

local function calculate_language_stats(repos)
    local lang_count = {}
    for _, repo in ipairs(repos) do
        if repo.language then
            lang_count[repo.language] = (lang_count[repo.language] or 0) + 1
        end
    end

    local lang_stats = {}
    for lang, count in pairs(lang_count) do
        table.insert(lang_stats, { language = lang, count = count })
    end

    table.sort(lang_stats, function(a, b)
        return a.count > b.count
    end)
    return lang_stats
end

local function format_recent_activity(events)
    local activity = {}
    for i = 1, math.min(activity_count, #events) do
        local event = events[i]
        local action = event.type:gsub('Event', ''):lower()
        table.insert(activity, string.format('%s %s %s', event.created_at, action, event.repo.name))
    end
    return table.concat(activity, '\n')
end

local function format_message(stats, repos, events, contrib_data)
    local total_stars = 0
    local most_starred_repo = { name = '', stars = 0 }
    for _, repo in ipairs(repos) do
        total_stars = total_stars + repo.stargazers_count
        if repo.stargazers_count > most_starred_repo.stars then
            most_starred_repo = { name = repo.name, stars = repo.stargazers_count }
        end
    end

    local lang_stats = calculate_language_stats(repos)
    local top_langs = ''
    for i = 1, math.min(top_lang_count, #lang_stats) do
        top_langs = top_langs .. string.format('%s (%d), ', lang_stats[i].language, lang_stats[i].count)
    end

    local recent_activity = format_recent_activity(events)
    local contrib_graph = generate_contribution_graph(contrib_data)

    return string.format(
        'Username: %s\nName: %s\nFollowers: %d\nFollowing: %d\nPublic Repos: %d\n'
            .. 'Total Stars: %d\nMost Starred Repo: %s (%d stars)\n'
            .. 'Top Languages: %s\n'
            .. 'Bio: %s\nLocation: %s\nCompany: %s\nBlog: %s\n'
            .. 'Created At: %s\nLast Updated: %s\n\n'
            .. 'Recent Activity:\n%s\n\n'
            .. 'Contribution Graph:\n%s',
        stats.login,
        stats.name or 'N/A',
        stats.followers,
        stats.following,
        #repos,
        total_stars,
        most_starred_repo.name,
        most_starred_repo.stars,
        top_langs,
        stats.bio or 'N/A',
        stats.location or 'N/A',
        stats.company or 'N/A',
        stats.blog or 'N/A',
        stats.created_at,
        stats.updated_at,
        recent_activity,
        contrib_graph
    )
end

function M.show_github_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            process_notification_queue()
            return
        end

        get_user_repos(stats.login, function(repos)
            get_user_events(stats.login, function(events)
                get_contribution_data(stats.login, function(contrib_data)
                    local message = format_message(stats, repos, events, contrib_data)
                    show_stats_window(message)
                    process_notification_queue()
                end)
            end)
        end)
    end)
end

function M.open_github_profile(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            process_notification_queue()
            return
        end

        local url = stats.html_url
        local open_command
        if vim.fn.has('mac') == 1 then
            open_command = 'open'
        elseif vim.fn.has('unix') == 1 then
            open_command = 'xdg-open'
        else
            open_command = 'start'
        end

        os.execute(open_command .. ' ' .. url)
        queue_notification('Opened GitHub profile: ' .. url, vim.log.levels.INFO)
        process_notification_queue()
    end)
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local devicons = require('nvim-web-devicons')
local os = require('os')
local Path = require('plenary.path')

local PROJECTS_DIR = Path:new(vim.fn.expand('~/Projects/GitHub/Maintain/')):absolute()

local function entry_maker(repo)
    local filetype = language_to_filetype(repo.language) or ''
    local icon, icon_highlight = devicons.get_icon(filetype, { default = true })
    local display = icon and ('%s %s [%s]'):format(icon, repo.name, repo.language)
        or ('%s [%s]'):format(repo.name, repo.language)
    return {
        value = repo,
        display = display,
        ordinal = repo.name,
        path = repo.name,
    }
end

local function format_repo_info(entry_value)
    return string.format(
        'Name: %s\nDescription: %s\nStars: %d\nForks: %d\nLanguage: %s\nCreated At: %s\nLast Updated: %s',
        entry_value.name,
        entry_value.description or 'N/A',
        entry_value.stargazers_count,
        entry_value.forks_count,
        entry_value.language or 'N/A',
        entry_value.created_at,
        entry_value.updated_at
    )
end

local function open_repo(repo_dir)
    local open_cmd = string.format('tea %s', repo_dir)
    local open_result = os.execute(open_cmd)
    if open_result ~= 0 then
        show_notification('Failed to open repository', vim.log.levels.ERROR)
    end
end

local function clone_and_open_repo(selection, repo_dir)
    local clone_cmd =
        string.format('gh repo clone %s/%s %s', selection.value.owner.login, selection.value.name, repo_dir)

    show_notification('Cloning repository: ' .. selection.value.name, vim.log.levels.INFO)

    async_execute(clone_cmd, function(result)
        if result then
            open_repo(repo_dir)
        end
    end)
end

local function handle_selection(prompt_bufnr, selection)
    actions.close(prompt_bufnr)
    if selection then
        local repo_dir = Path:new(PROJECTS_DIR, selection.value.name):absolute()
        if Path:new(repo_dir):exists() then
            open_repo(repo_dir)
        else
            clone_and_open_repo(selection, repo_dir)
        end
    end
end

function M.search_repos(username)
    get_user_repos(username, function(repos)
        vim.schedule(function()
            pickers
                .new({}, {
                    prompt_title = 'Select a repository:',
                    finder = finders.new_table({
                        results = repos,
                        entry_maker = entry_maker,
                    }),
                    sorter = sorters.get_generic_fuzzy_sorter(),
                    previewer = previewers.new_buffer_previewer({
                        define_preview = function(self, entry, status)
                            local repo_info = format_repo_info(entry.value)
                            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(repo_info, '\n'))
                        end,
                    }),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            handle_selection(prompt_bufnr, selection)
                        end)
                        return true
                    end,
                })
                :find()
        end)
    end)
end

vim.api.nvim_create_user_command('GitHubStats', function(opts)
    M.show_github_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('GitHubProfile', function(opts)
    M.open_github_profile(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('GitHubRepos', function(opts)
    M.search_repos(opts.args)
end, { nargs = '?' })

return M
