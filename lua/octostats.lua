local vim = vim
local M = {}
local top_lang_count = 5
local activity_count = 5
local octorepos_present, octorepos = pcall(require, 'octorepos')
local utils = require('octostats.utils')

local function select_emoji(contributionCount)
    if contributionCount == 0 then
        return ''
    elseif contributionCount <= 10 then
        return ''
    elseif contributionCount <= 20 then
        return ''
    elseif contributionCount <= 30 then
        return ''
    elseif contributionCount <= 40 then
        return ''
    elseif contributionCount <= 50 then
        return ''
    else
        return ''
    end
end

local function get_github_stats(username, callback)
    local command = username == '' and 'gh api user' or 'gh api users/' .. username
    utils.get_data_with_cache('user_' .. username, command, callback)
end

local function get_user_events(username, callback)
    local command = 'gh api users/' .. username .. '/events?per_page=100'
    utils.get_data_with_cache('events_' .. username, command, callback)
end

local function get_contribution_data(username, callback)
    local command = 'gh api graphql -f query=\'{user(login: "'
        .. username
        .. '") { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount } } } } } }\''
    utils.get_data_with_cache('contrib_' .. username, command, callback)
end

local function get_contribution_graph(contrib_data)
    local calendar = contrib_data.data.user.contributionsCollection.contributionCalendar
    local graph_parts = {
        string.format('%-4s\t %-4s\t %-4s\t %-4s\t %-4s\t %-4s\t %-4s\n', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'),
    }
    for _, week in ipairs(calendar.weeks) do
        for _, day in ipairs(week.contributionDays) do
            local emoji = select_emoji(day.contributionCount)
            local padded_count = string.format('%4d\t', day.contributionCount)
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
            local height = math.min(40, vim.o.lines - 4)
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

local function get_recent_activity(events)
    local activity = {}
    for i = 1, math.min(activity_count, #events) do
        local event = events[i]
        local action = event.type:gsub('Event', ''):lower()
        table.insert(activity, string.format('%s %s %s', event.created_at, action, event.repo.name))
    end
    return table.concat(activity, '\n')
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

local function get_repo_stats(repos)
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

    return string.format(
        'Total Stars: %d\nMost Starred Repo: %s (%d stars)\n' .. 'Top Languages: %s',
        total_stars,
        most_starred_repo.name,
        most_starred_repo.stars,
        top_langs
    )
end

local function format_message(stats, repos, events, contrib_data)
    local message = string.format(
        ' Username: %s\t Name: %s\n Followers: %d\t Following: %d\n Public Repos: %d\n'
            .. ' Bio: %s\n Location: %s\n Company: %s\n Website: %s\n'
            .. ' Created At: %s\n Last Updated: %s\n',
        stats.login,
        stats.name or 'N/A',
        stats.followers,
        stats.following,
        stats.public_repos,
        stats.bio or 'N/A',
        stats.location or 'N/A',
        stats.company or 'N/A',
        stats.blog or 'N/A',
        stats.created_at,
        stats.updated_at
    )

    if repos and #repos > 0 then
        message = message .. string.format('\n Repos:\n%s\n', get_repo_stats(repos))
    end
    message = message .. string.format('\n Recent Activity:\n%s\n', get_recent_activity(events))
    message = message .. string.format('\n Contribution Graph:\n%s\n', get_contribution_graph(contrib_data))
    return message
end

function M.show_github_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            utils.process_notification_queue()
            return
        end

        if octorepos_present then
            octorepos.get_user_repos(stats.login, function(repos)
                get_user_events(stats.login, function(events)
                    get_contribution_data(stats.login, function(contrib_data)
                        local message = format_message(stats, repos, events, contrib_data)
                        show_stats_window(message)
                        utils.process_notification_queue()
                    end)
                end)
            end)
        else
            get_user_events(stats.login, function(events)
                get_contribution_data(stats.login, function(contrib_data)
                    local message = format_message(stats, {}, events, contrib_data)
                    show_stats_window(message)
                    utils.process_notification_queue()
                end)
            end)
        end
    end)
end

function M.open_github_profile(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            utils.process_notification_queue()
            return
        end

        local url = stats.html_url
        utils.open_command(url)
        utils.queue_notification('Opened GitHub profile: ' .. url, vim.log.levels.INFO)
        utils.process_notification_queue()
    end)
end

return M
