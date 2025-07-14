local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')
local config = require('octohub.config').config
local legacy = require('octohub.legacy')

local M = {}

---Add a normal mode keymap for a command
---@param keys string
---@param cmd string
---@param desc string
local function add_keymap(keys, cmd, desc)
    vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
end

---Helper to add a Neovim user command
---@param name string
---@param func fun(opts: table)
---@param opts? table
local function add_command(name, func, opts)
    vim.api.nvim_create_user_command(name, func, opts or {})
end

---Add all default keymaps for Octohub commands
local function add_default_keymaps()
    add_keymap('<leader>goo', ':Octohub repos<CR>', 'All Repos')

    add_keymap('<leader>gob', ':Octohub repos sort:size<CR>', 'Repos by Size')
    add_keymap('<leader>goc', ':Octohub repos sort:created<CR>', 'Repos by Created')
    add_keymap('<leader>gof', ':Octohub repos sort:forks<CR>', 'Repos by Forks')
    add_keymap('<leader>goi', ':Octohub repos sort:issues<CR>', 'Repos by Issues')
    add_keymap('<leader>gol', ':Octohub repos sort:language<CR>', 'Repos by Language')
    add_keymap('<leader>gos', ':Octohub repos sort:stars<CR>', 'Repos by Stars')
    add_keymap('<leader>gou', ':Octohub repos sort:updated<CR>', 'Repos by Updated')
    add_keymap('<leader>goU', ':Octohub repos sort:pushed<CR>', 'Repos by Pushed')

    add_keymap('<leader>goA', ':Octohub repos type:archived<CR>', 'Archived Repos')
    add_keymap('<leader>goF', ':Octohub repos type:forked<CR>', 'Forked Repos')
    add_keymap('<leader>goP', ':Octohub repos type:private<CR>', 'Private Repos')
    add_keymap('<leader>goS', ':Octohub repos type:starred<CR>', 'Starred Repos')
    add_keymap('<leader>goT', ':Octohub repos type:template<CR>', 'Template Repos')

    add_keymap('<leader>goa', ':Octohub stats activity<CR>', 'Activity Stats')
    add_keymap('<leader>gog', ':Octohub stats contributions<CR>', 'Contribution Graph')
    add_keymap('<leader>gor', ':Octohub stats repo<CR>', 'Repo Stats')
    add_keymap('<leader>got', ':Octohub stats<CR>', 'All Stats')

    add_keymap('<leader>gop', ':Octohub web profile<CR>', 'Open GitHub Profile')
    add_keymap('<leader>gow', ':Octohub web repo<CR>', 'Open Repo in Browser')
end

---Completion for Octohub subcommands
---@return string[]
local function complete_repos_subcommands()
    return { 'repos', 'repo', 'stats', 'web' }
end

---Completion for repos sort/type params
---@return string[]
local function complete_repos_params()
    return {
        'sort:created',
        'sort:forks',
        'sort:issues',
        'sort:language',
        'sort:name',
        'sort:pushed',
        'sort:size',
        'sort:stars',
        'sort:updated',
        'type:archived',
        'type:forked',
        'type:private',
        'type:starred',
        'type:template',
    }
end

---Completion for stats subcommands
---@return string[]
local function complete_stats_subcommands()
    return { 'activity', 'contributions', 'repo' }
end

---Completion for web subcommands
---@return string[]
local function complete_web_subcommands()
    return { 'profile', 'repo' }
end

---Main completion function for Octohub command
---@param arglead string
---@param cmdline string
---@param cursorpos integer
---@return string[]
local function complete_octohub(arglead, cmdline, cursorpos)
    local args = vim.split(cmdline, ' ')
    local arg_count = #args

    args = vim.tbl_filter(function(arg)
        return arg ~= ''
    end, args)

    if arg_count == 2 then
        return vim.tbl_filter(function(cmd)
            return cmd:sub(1, #arglead) == arglead
        end, complete_repos_subcommands())
    elseif arg_count > 2 then
        local subcommand = args[2]
        if subcommand == 'repos' then
            return vim.tbl_filter(function(param)
                return param:sub(1, #arglead) == arglead
            end, complete_repos_params())
        elseif subcommand == 'stats' and arg_count == 3 then
            return vim.tbl_filter(function(cmd)
                return cmd:sub(1, #arglead) == arglead
            end, complete_stats_subcommands())
        elseif subcommand == 'web' and arg_count == 3 then
            return vim.tbl_filter(function(cmd)
                return cmd:sub(1, #arglead) == arglead
            end, complete_web_subcommands())
        end
    end

    return {}
end

---Add the main Octohub command
local function add_octohub_command()
    add_command('Octohub', function(opts)
        local args = vim.split(opts.args, ' ')
        args = vim.tbl_filter(function(arg)
            return arg ~= ''
        end, args)

        if #args == 0 then
            repos.show_repos('', config.sort_repos_by, config.repo_type)
        end

        local subcommand = args[1]

        if subcommand == 'repos' then
            local user_arg, sort_arg, type_arg = '', '', ''

            for i = 2, #args do
                local arg = args[i]
                if arg:match('^sort:') then
                    sort_arg = arg:sub(6)
                elseif arg:match('^type:') then
                    type_arg = arg:sub(6)
                else
                    user_arg = arg
                end
            end

            repos.show_repos(user_arg, sort_arg, type_arg)
        elseif subcommand == 'repo' then
            if #args == 2 then
                repos.open_repo(args[2])
            elseif #args == 3 then
                repos.open_repo(args[3], args[2])
            else
                print('Usage: Octohub repo <name> [user]')
            end
        elseif subcommand == 'stats' then
            if #args == 1 then
                stats.show_all_stats('')
            elseif #args == 2 then
                if args[2] == 'activity' then
                    stats.show_activity_stats('', nil)
                elseif args[2] == 'contributions' then
                    stats.show_contribution_stats('')
                elseif args[2] == 'repo' then
                    stats.show_repo_stats('')
                else
                    stats.show_all_stats(args[2])
                end
            elseif #args >= 3 then
                local stats_subcommand = args[2]
                if stats_subcommand == 'activity' then
                    local user_arg, count_arg = '', ''
                    for i = 3, #args do
                        local arg = args[i]
                        if arg:match('^count:') then
                            count_arg = arg:sub(7)
                        else
                            user_arg = arg
                        end
                    end
                    stats.show_activity_stats(user_arg, tonumber(count_arg))
                elseif stats_subcommand == 'contributions' then
                    stats.show_contribution_stats(args[3])
                elseif stats_subcommand == 'repo' then
                    stats.show_repo_stats(args[3])
                end
            end
        elseif subcommand == 'web' then
            if #args == 1 then
                print('Usage: Octohub web <profile|repo> [user]')
            elseif args[2] == 'profile' then
                local user = #args > 2 and args[3] or ''
                web.open_github_profile(user)
            elseif args[2] == 'repo' then
                web.open_repo_web()
            else
                print('Usage: Octohub web <profile|repo> [user]')
            end
        else
            print('Unknown subcommand: ' .. subcommand)
            print('Usage: Octohub <subcommand> [options]')
            print('Available subcommands: repos, repo, stats, web')
        end
    end, { nargs = '*', complete = complete_octohub })
end

---Setup Octohub commands and keymaps
function M.setup()
    if config.use_new_command then
        add_octohub_command()
        if config.add_default_keybindings then
            add_default_keymaps()
        end
    else
        vim.notify(
            'Legacy Octohub commands are deprecated and will be removed on 15th August 2025.\n'
                .. 'Please switch the new `:Octohub` command by adding `use_new_command` in your config.\n'
                .. 'More info: https://github.com/2kabhishek/octohub.nvim/issues/13',
            vim.log.levels.WARN
        )
        legacy.add_repo_commands()
        legacy.add_stat_commands()
        legacy.add_web_commands()

        if config.add_default_keybindings then
            legacy.add_legacy_keymaps()
        end
    end
end

return M
