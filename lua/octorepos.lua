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

local PROJECTS_DIR = Path:new(vim.fn.expand('~/Projects/GitHub/Maintain/')):absolute()

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
    utils.async_execute('gh api user', function(result)
        local data = utils.safe_json_decode(result)
        if data then
            callback(data.login)
        end
    end)
end

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
        utils.show_notification('Failed to open repository', vim.log.levels.ERROR)
    end
end

local function clone_and_open_repo(selection, repo_dir)
    local clone_cmd =
        string.format('gh repo clone %s/%s %s', selection.value.owner.login, selection.value.name, repo_dir)

    utils.show_notification('Cloning repository: ' .. selection.value.name, vim.log.levels.INFO)

    utils.async_execute(clone_cmd, function(result)
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

M.get_user_repos = function(username, callback)
    local function process_username(username)
        local all_repos = {}

        local function fetch_page(page)
            local command = 'gh api users/' .. username .. '/repos?page=' .. page
            utils.get_data_with_cache('repos_' .. username .. '_page_' .. page, command, function(repos)
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
