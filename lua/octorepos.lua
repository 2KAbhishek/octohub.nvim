local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local devicons = require('nvim-web-devicons')
local Path = require('plenary.path')

---@class Octorepos
local M = {}

local utils = require('utils')
local languages = require('octorepos.languages')

---@class Octorepos.config
---@field top_lang_count number : Number of top languages to display
---@field per_user_dir boolean : Whether to create a directory for each user
---@field projects_dir string : Directory where repositories are cloned
---@field cache_timeout number : Time in seconds to cache data
local config = {
    top_lang_count = 5,
    per_user_dir = true,
    projects_dir = '~/Projects/GitHub/',
    cache_timeout = 24 * 3600,
}

---@type Octorepos.config
M.config = config

---@param args Octorepos.config
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

---@param repo table
---@return table
local function entry_maker(repo)
    local icon, _ = devicons.get_icon(repo.file_type, { default = true })
    icon = icon or ''

    local display = icon and ('%s %s [%s]'):format(icon, repo.name, repo.language)

    return {
        value = repo,
        display = display,
        ordinal = repo.name,
        path = repo.name,
    }
end

---@param repo table
---@return string
local function format_repo_info(repo)
    local repo_info = {
        string.format(' Repo Info\n\n Name: %s\n Language: %s\n', repo.name, repo.language),
    }

    table.insert(
        repo_info,
        string.format(
            ' Link: %s\n\n'
                .. ' Stars: %d\n Forks: %d\n Watchers: %d\n Open Issues: %d\n\n'
                .. ' Owner: %s\n Created At: %s\n Last Updated: %s\n Size: %d KB\n',
            repo.html_url,
            repo.stargazers_count,
            repo.forks_count,
            repo.watchers_count,
            repo.open_issues_count,
            repo.owner.login,
            utils.human_time(repo.created_at),
            utils.human_time(repo.updated_at),
            repo.size
        )
    )

    local conditional_additions = {
        {
            repo.description ~= vim.NIL and #repo.description > 0,
            string.format(' Description: %s\n', repo.description),
            2,
        },
        { repo.homepage ~= vim.NIL and #repo.homepage > 0, string.format(' Homepage: %s\n', repo.homepage), 3 },
        { repo.fork, '\n Forked\n' },
        { repo.archived, '\n Archived\n' },
        { repo.private, '\n Private\n' },
        { repo.is_template, '\n Template\n' },
        { #repo.topics > 0, string.format('\n Topics: %s\n', table.concat(repo.topics, ', ')) },
    }

    for _, conditional_addition in ipairs(conditional_additions) do
        local condition = conditional_addition[1]
        local content = conditional_addition[2]
        local content_position = conditional_addition[3]

        if condition then
            if content_position == nil then
                table.insert(repo_info, content)
            else
                table.insert(repo_info, content_position, content)
            end
        end
    end

    return table.concat(repo_info)
end

---@param prompt_bufnr number
---@param selection table
local function handle_selection(prompt_bufnr, selection)
    actions.close(prompt_bufnr)
    if selection then
        local owner = selection.value.owner.login
        local repo_name = selection.value.name
        M.open_repo(repo_name, owner)
    end
end

---@param repos table
---@return table
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

---@param callback fun(result: string)
local function get_default_username(callback)
    utils.get_data_from_cache('default_username', 'gh api user', function(data)
        if data then
            callback(data.login)
        end
    end, M.config.cache_timeout)
end

---@param repo_name string
---@param owner string
---@return string
local function get_repo_dir(repo_name, owner)
    if not Path:new(M.config.projects_dir):exists() then
        vim.fn.mkdir(M.config.projects_dir)
    end

    local repo_dir
    if M.config.per_user_dir then
        local owner_dir = Path:new(vim.fn.expand(M.config.projects_dir), owner):absolute()
        if not Path:new(owner_dir):exists() then
            vim.fn.mkdir(owner_dir)
        end

        repo_dir = Path:new(owner_dir, repo_name):absolute()
    else
        repo_dir = Path:new(vim.fn.expand(M.config.projects_dir), repo_name):absolute()
    end
    return repo_dir
end

---@param repo_name string
---@param owner string
M.open_repo = function(repo_name, owner)
    local repo_dir
    if not owner then
        get_default_username(function(default_username)
            owner = default_username
        end)
    end
    repo_dir = get_repo_dir(repo_name, owner)

    if not Path:new(repo_dir):exists() then
        local clone_cmd = string.format('gh repo clone %s/%s %s', owner, repo_name, repo_dir)

        utils.show_notification('Cloning repository: ' .. owner .. '/' .. repo_name, vim.log.levels.INFO)

        utils.async_shell_execute(clone_cmd, function(result)
            if result then
                utils.open_dir(repo_dir)
            end
        end)
    else
        utils.open_dir(repo_dir)
    end
end

---@param repos table
---@return string
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
    for i = 1, math.min(M.config.top_lang_count, #lang_stats) do
        top_langs = top_langs .. string.format('\n%d. %s (%d)', i, lang_stats[i].language, lang_stats[i].count)
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

---@param username? string
M.show_repo_stats = function(username)
    M.get_user_repos(username, function(repos)
        local repo_stats = M.get_repo_stats(repos)
        utils.queue_notification(repo_stats, vim.log.levels.INFO)
    end)
end

---@param username? string
---@param callback fun(data: any)
M.get_user_repos = function(username, callback)
    local function process_username(user_to_process, is_auth_user)
        local all_repos = {}
        local function fetch_page(page)
            local command
            local auth = is_auth_user and 'auth_' or ''
            if is_auth_user then
                command = string.format(
                    'gh api -H "Accept: application/vnd.github.v3+json" "/user/repos?page=%d&per_page=100&type=all"',
                    page
                )
            else
                command = string.format('gh api "users/%s/repos?page=%d&per_page=100"', user_to_process, page)
            end

            utils.get_data_from_cache('repos_' .. auth .. user_to_process .. '_page_' .. page, command, function(repos)
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
            end, M.config.cache_timeout)
        end
        fetch_page(1)
    end

    get_default_username(function(default_username)
        local is_auth_user = username == nil or username == ''
        local user_to_process = is_auth_user and default_username or username
        process_username(user_to_process, is_auth_user)
    end)
end

---@param username? string
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
                        define_preview = function(self, entry, _)
                            local repo_info = format_repo_info(entry.value)
                            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(repo_info, '\n'))
                        end,
                    }),
                    attach_mappings = function(prompt_bufnr, _)
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
