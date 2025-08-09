local Path = require('plenary.path')

local config = require('octohub.config').config
local icons = config.icons

local cache = require('utils.cache')
local time = require('utils.time')
local noti = require('utils.notification')
local shell = require('utils.shell')
local lang = require('utils.language')

local pickme = require('pickme')

---@class OctohubRepos
local M = {}

---@param repo table
---@return table
local function entry_maker(repo)
    local icon = lang.get_language_icon(repo.language)
    local display = icon and ('%s %s [%s]'):format(icon, repo.name, repo.language)

    return {
        value = repo,
        display = display,
        ordinal = repo.name .. ' ' .. repo.language,
        path = repo.name,
    }
end

---@param repo table
---@return string
local function format_repo_info(repo)
    local repo_info = {
        string.format('# %s\n\n%s  Language: %s\n', repo.name, repo.icon, repo.language),
    }

    table.insert(
        repo_info,
        string.format(
            '%s [Link](%s)\n\n'
                .. '%s Stars: %d\n%s Forks: %d\n%s Watchers: %d\n%s Open Issues: %d\n\n'
                .. '%s Owner: %s\n%s Created At: %s\n%s Last Updated: %s\n%s Disk Usage: %d\n',
            icons.link,
            repo.html_url,
            icons.star,
            repo.stargazers_count,
            icons.fork,
            repo.forks_count,
            icons.watch,
            repo.watchers_count,
            icons.issue,
            repo.open_issues_count,
            icons.user,
            repo.owner.login,
            icons.calendar,
            time.human_time(repo.created_at),
            icons.clock,
            time.human_time(repo.updated_at),
            icons.disk,
            repo.size
        )
    )

    local conditional_additions = {
        {
            repo.description ~= vim.NIL and #repo.description > 0,
            string.format('%s %s\n', icons.info, repo.description),
            2,
        },
        {
            repo.homepage ~= vim.NIL and #repo.homepage > 0,
            string.format('%s [Homepage](%s)\n', icons.home, repo.homepage),
            3,
        },
        { repo.fork, string.format('\n> %s Forked\n', icons.fork_alt) },
        { repo.archived, string.format('\n> %s Archived\n', icons.archive) },
        { repo.private, string.format('\n> %s Private\n', icons.lock) },
        { repo.is_template, string.format('\n> %s Template\n', icons.template) },
        { #repo.topics > 0, string.format('\n%s Topics: %s\n', icons.tag, table.concat(repo.topics, ', ')) },
    }

    for _, conditional_addition in ipairs(conditional_additions) do
        local condition = conditional_addition[1]
        local content = conditional_addition[2]
        local content_position = conditional_addition[3]

        if condition then
            table.insert(repo_info, content_position or #repo_info + 1, content)
        end
    end

    return table.concat(repo_info)
end

---@param prompt_bufnr number
---@param selection table
local function handle_selection(prompt_bufnr, selection)
    if selection then
        local owner = selection.value.owner.login
        local repo_name = selection.value.name
        M.open_repo(repo_name, owner)
    end
end

---@param callback fun(result: string)
function M.get_default_username(callback)
    cache.get_data_from_cache('default_username', 'gh api user', function(data)
        if data then
            callback(data.login)
        end
    end, config.cache.username)
end

---@param repo_name string
---@param owner string?
---@return string
local function get_repo_dir(repo_name, owner)
    local projects_dir = Path:new(vim.fn.expand(config.repos.projects_dir))
    projects_dir:mkdir({ parents = true, exists_ok = true })

    local repo_dir
    if config.repos.per_user_dir then
        local owner_dir = projects_dir:joinpath(owner)
        owner_dir:mkdir({ parents = true, exists_ok = true })
        repo_dir = owner_dir:joinpath(repo_name)
    else
        repo_dir = projects_dir:joinpath(repo_name)
    end
    return repo_dir:absolute()
end

---@param repos table
---@param sort_by string
local function sort_repos(repos, sort_by)
    if #sort_by > 0 then
        return table.sort(repos, function(a, b)
            if sort_by:match('^push') then
                return a.pushed_at > b.pushed_at
            elseif sort_by:match('^create') then
                return a.created_at > b.created_at
            elseif sort_by:match('^update') then
                return a.updated_at > b.updated_at
            elseif sort_by:match('^star') then
                return a.stargazers_count > b.stargazers_count
            elseif sort_by:match('^fork') then
                return a.forks_count > b.forks_count
            elseif sort_by:match('^size') then
                return a.size > b.size
            elseif sort_by:match('^issue') then
                return a.open_issues_count > b.open_issues_count
            elseif sort_by:match('^name') then
                return a.name < b.name
            elseif sort_by:match('^language') then
                return a.language < b.language
            end
        end)
    end
end

---@param repos table
---@param repo_type string
---@param language string?
---@return table
local function filter_repos(repos, repo_type, language)
    local filtered = repos

    if #repo_type > 0 then
        local type_filtered = {}
        for _, repo in ipairs(filtered) do
            local should_include = false
            if repo_type:match('^private') then
                should_include = repo.private
            elseif repo_type:match('^fork') then
                should_include = repo.fork
            elseif repo_type:match('^archive') then
                should_include = repo.archived
            elseif repo_type:match('^template') then
                should_include = repo.is_template
            else
                should_include = true
            end

            if should_include then
                table.insert(type_filtered, repo)
            end
        end
        filtered = type_filtered
    end

    if language and #language > 0 then
        local lang_filtered = {}
        local target_lang = language:lower()
        for _, repo in ipairs(filtered) do
            local repo_lang = repo.language and repo.language:lower() or ''
            if repo_lang == target_lang then
                table.insert(lang_filtered, repo)
            end
        end
        filtered = lang_filtered
    end

    return filtered
end

---@param repo_name string
---@param owner string?
function M.open_repo(repo_name, owner)
    local repo_dir
    if not owner then
        M.get_default_username(function(default_username)
            owner = default_username
        end)
    end
    repo_dir = get_repo_dir(repo_name, owner)

    if not Path:new(repo_dir):exists() then
        local clone_cmd = string.format('gh repo clone %s/%s %s', owner, repo_name, repo_dir)

        noti.show_notification('Cloning repository: ' .. owner .. '/' .. repo_name, vim.log.levels.INFO, 'Octohub')

        shell.async_shell_execute(clone_cmd, function(result)
            if result then
                shell.open_session_or_dir(repo_dir)
            end
        end)
    else
        shell.open_session_or_dir(repo_dir)
    end
end

---Get list of languages used in user's repositories
---@param username string?
---@param callback fun(languages: string[]|table[])
---@param with_counts boolean? Include counts in the language list
function M.get_language_list(username, callback, with_counts)
    local function process_repos_for_languages(repos)
        local lang_count = {}
        for _, repo in ipairs(repos) do
            if repo.language and repo.language ~= vim.NIL and repo.language ~= '' then
                lang_count[repo.language] = (lang_count[repo.language] or 0) + 1
            end
        end

        local languages = {}
        for lang, count in pairs(lang_count) do
            table.insert(languages, { name = lang, count = count })
        end

        table.sort(languages, function(a, b)
            return a.name < b.name
        end)

        if with_counts then
            callback(languages)
        else
            local language_names = {}
            for _, lang_info in ipairs(languages) do
                table.insert(language_names, lang_info.name)
            end
            callback(language_names)
        end
    end

    M.get_default_username(function(default_username)
        local user_to_process = username and #username > 0 and username or default_username

        M.get_repos({ username = username }, function(repos)
            process_repos_for_languages(repos)
        end)
    end)
end

---Show interactive language picker and filter repos by selected language
---@param username string?
function M.show_language_picker(username)
    local with_counts = true
    M.get_language_list(username, function(languages)
        vim.schedule(function()
            if #languages == 0 then
                noti.show_notification('No languages found in repositories', vim.log.levels.WARN, 'Octohub')
                return
            end

            vim.ui.select(languages, {
                prompt = 'Select language to filter repos:',
                format_item = function(item)
                    return string.format('%s (%d)', item.name, item.count)
                end,
            }, function(selected)
                if selected then
                    M.show_repos(username or '', '', '', selected.name)
                end
            end)
        end)
    end, with_counts)
end

---Get list of repository names for the default user only
---@param callback fun(repo_names: string[])
function M.get_default_user_repo_list(callback)
    M.get_default_username(function(default_username)
        M.get_repos({ username = '' }, function(repos)
            local repo_names = {}
            for _, repo in ipairs(repos) do
                if repo.owner and repo.owner.login == default_username then
                    table.insert(repo_names, repo.name)
                end
            end

            table.sort(repo_names)
            callback(repo_names)
        end)
    end)
end

---@param args? table
---@param callback fun(data: any)
function M.get_repos(args, callback)
    local username = args and args.username or ''
    local sort_by = args and args.sort_by or config.repos.sort_by
    local repo_type = args and args.repo_type or config.repos.repo_type
    local language = args and args.language or config.repos.language

    local function get_user_repos(user_to_process, is_auth_user)
        local all_repos = {}
        local cache_prefix = 'repos_'
        local function fetch_page(page)
            local command = string.format('gh api "users/%s/repos?page=%d&per_page=100"', user_to_process, page)
            if is_auth_user then
                cache_prefix = cache_prefix .. 'auth_'
                command = string.format(
                    'gh api -H "Accept: application/vnd.github.v3+json" "/user/repos?page=%d&per_page=100&type=all"',
                    page
                )
            end
            if repo_type:match('^star') then
                cache_prefix = cache_prefix .. 'star_'
                command = string.format('gh api "users/%s/starred?page=%d&per_page=100"', user_to_process, page)
            end

            cache.get_data_from_cache(cache_prefix .. user_to_process .. '_page_' .. page, command, function(repos)
                if repos and #repos > 0 then
                    for _, repo in ipairs(repos) do
                        if repo.language == vim.NIL then
                            repo.language = 'Markdown'
                        end
                        repo.icon = lang.get_language_icon(repo.language)
                        table.insert(all_repos, repo)
                    end
                    fetch_page(page + 1)
                else
                    sort_repos(all_repos, sort_by)
                    all_repos = filter_repos(all_repos, repo_type, language)
                    callback(all_repos)
                end
            end, config.cache.repos)
        end
        fetch_page(1)
    end

    M.get_default_username(function(default_username)
        local is_auth_user = username == nil or username == ''
        local user_to_process = is_auth_user and default_username or username
        get_user_repos(user_to_process, is_auth_user)
    end)
end

---@param username string?
---@param sort_by string?
---@param repo_type string?
---@param language string?
function M.show_repos(username, sort_by, repo_type, language)
    sort_by = #sort_by > 0 and sort_by or config.repos.sort_by
    repo_type = #repo_type > 0 and repo_type or config.repos.repo_type

    M.get_repos({ username = username, sort_by = sort_by, repo_type = repo_type, language = language }, function(repos)
        vim.schedule(function()
            pickme.custom_picker({
                items = repos,
                title = 'Select a repository',
                entry_maker = entry_maker,
                preview_generator = format_repo_info,
                selection_handler = handle_selection,
            })
        end)
    end)
end

return M
