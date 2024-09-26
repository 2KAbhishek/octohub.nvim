local vim = vim
local Job = require('plenary.job')
local M = {}
local cache = {}
local cache_timeout = 900 -- 15 minutes
local notification_queue = {}

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local devicons = require('nvim-web-devicons')
local os = require('os')
local Path = require('plenary.path')


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

function M.show_repos(username)
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

return M
