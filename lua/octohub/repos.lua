local Path = require('plenary.path')

local config = require('octohub.config').config

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
        string.format('# %s\n\n%s Language: %s\n', repo.name, repo.icon, repo.language),
    }

    table.insert(
        repo_info,
        string.format(
            ' [Link](%s)\n\n'
                .. ' Stars: %d\n Forks: %d\n Watchers: %d\n Open Issues: %d\n\n'
                .. ' Owner: %s\n Created At: %s\n Last Updated: %s\n Disk Usage: %d\n',
            repo.html_url,
            repo.stargazers_count,
            repo.forks_count,
            repo.watchers_count,
            repo.open_issues_count,
            repo.owner.login,
            time.human_time(repo.created_at),
            time.human_time(repo.updated_at),
            repo.size
        )
    )

    local conditional_additions = {
        {
            repo.description ~= vim.NIL and #repo.description > 0,
            string.format(' %s\n', repo.description),
            2,
        },
        { repo.homepage ~= vim.NIL and #repo.homepage > 0, string.format(' [Homepage](%s)\n', repo.homepage), 3 },
        { repo.fork, '\n>  Forked\n' },
        { repo.archived, '\n>  Archived\n' },
        { repo.private, '\n>  Private\n' },
        { repo.is_template, '\n>  Template\n' },
        { #repo.topics > 0, string.format('\n Topics: %s\n', table.concat(repo.topics, ', ')) },
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
---@return table
local function filter_repos(repos, repo_type)
    if #repo_type > 0 then
        local filtered = {}
        for _, repo in ipairs(repos) do
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
                table.insert(filtered, repo)
            end
        end
        return filtered
    end
    return repos
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

---@param args? table
---@param callback fun(data: any)
function M.get_repos(args, callback)
    local username = args and args.username or ''
    local sort_by = args and args.sort_by or config.repos.sort_by
    local repo_type = args and args.repo_type or config.repos.repo_type

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
                    all_repos = filter_repos(all_repos, repo_type)
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
function M.show_repos(username, sort_by, repo_type)
    sort_by = #sort_by > 0 and sort_by or config.repos.sort_by
    repo_type = #repo_type > 0 and repo_type or config.repos.repo_type

    M.get_repos({ username = username, sort_by = sort_by, repo_type = repo_type }, function(repos)
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
