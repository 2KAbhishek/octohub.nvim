local vim = vim
local M = {}
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local devicons = require('nvim-web-devicons')
local os = require('os')
local Path = require('plenary.path')

local utils = require('octorepos.utils')
local languages = require('octorepos.languages')

local top_lang_count = 5
local PROJECTS_DIR = Path:new(vim.fn.expand('~/Projects/GitHub/Maintain/')):absolute()

local function get_default_username(callback)
    utils.async_shell_execute('gh api user', function(result)
        local data = utils.safe_json_decode(result)
        if data then
            callback(data.login)
        end
    end)
end

local function entry_maker(repo)
    local icon, icon_highlight = devicons.get_icon(repo.file_type, { default = true })
    icon = icon or ''

    local display = icon and ('%s %s [%s]'):format(icon, repo.name, repo.language)

    return {
        value = repo,
        display = display,
        ordinal = repo.name,
        path = repo.name,
    }
end

local function format_repo_info(repo)
    return string.format(
        ' Repo Info\n\n'
            .. ' Name: %s\n Description: %s\n Language: %s\n'
            .. ' Homepage: %s\n Link: %s\n\n'
            .. ' Stars: %d\n Forks: %d\n Watchers: %d\n Open Issues: %d\n\n'
            .. ' Owner: %s\n Created At: %s\n Last Updated: %s\n'
            .. ' Size: %d KB\n Fork: %s\n Archive: %s\n\n'
            .. ' Topics: %s\n',
        repo.name,
        repo.description,
        repo.language,
        repo.homepage,
        repo.html_url,
        repo.stargazers_count,
        repo.forks_count,
        repo.watchers_count,
        repo.open_issues_count,
        repo.owner.login,
        repo.created_at,
        repo.updated_at,
        repo.size,
        repo.fork and 'Yes' or 'No',
        repo.archived and 'Yes' or 'No',
        table.concat(repo.topics, ', ')
    )
end

local function open_repo(repo_dir)
    local open_cmd = string.format('tea %s', repo_dir)
    local open_result = os.execute(open_cmd)
    if open_result ~= 0 then
        utils.show_notification('Failed to open repository', vim.log.levels.ERROR)
    end
end

local function clone_and_open_repo(selection, repo_dir)
    local clone_cmd =
        string.format('gh repo clone %s/%s %s', selection.value.owner.login, selection.value.name, repo_dir)

    utils.show_notification('Cloning repository: ' .. selection.value.name, vim.log.levels.INFO)

    utils.async_shell_execute(clone_cmd, function(result)
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

M.get_repo_stats = function(repos)
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
        ' Public Repos: %d\n Total Stars: %d\n Most Starred Repo: %s (%d stars)\n♥ Top Languages: %s',
        #repos,
        total_stars,
        most_starred_repo.name,
        most_starred_repo.stars,
        top_langs
    )
end

M.show_repo_stats = function(username)
    M.get_user_repos(username, function(repos)
        local repo_stats = M.get_repo_stats(repos)
        utils.queue_notification(repo_stats, vim.log.levels.INFO)
    end)
end

M.get_user_repos = function(username, callback)
    local function process_username(username)
        local all_repos = {}

        local function fetch_page(page)
            local command = 'gh api users/' .. username .. '/repos?page=' .. page
            utils.get_data_with_cache('repos_' .. username .. '_page_' .. page, command, function(repos)
                if repos and #repos > 0 then
                    for _, repo in ipairs(repos) do
                        local file_type = languages.language_to_filetype(repo.language)
                        if file_type == 'md' then
                            repo.language = 'Markdown'
                        end
                        repo.file_type = file_type
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

M.show_repos = function(username)
    M.get_user_repos(username, function(repos)
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

return M
