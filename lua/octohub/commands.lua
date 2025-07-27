local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')
local config = require('octohub.config').config
local legacy = require('octohub.legacy')

---@class OctohubCommands
local M = {}

---Add all default keymaps for Octohub commands
local function add_default_keymaps()
    local function add_keymap(keys, cmd, desc)
        vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
    end

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

---Parse command line arguments, removing empty strings
---@param cmdline string
---@return string[]
local function parse_args(cmdline)
    local args = vim.split(cmdline, ' ')
    return vim.tbl_filter(function(arg)
        return arg ~= ''
    end, args)
end

---Filter items by prefix match
---@param items string[]
---@param prefix string
---@return string[]
local function filter_by_prefix(items, prefix)
    return vim.tbl_filter(function(item)
        return item:sub(1, #prefix) == prefix
    end, items)
end

---Get completion options for different contexts
---@param context string
---@return string[]
local function get_completion_options(context)
    local options = {
        subcommands = { 'repos', 'repo', 'stats', 'web' },
        repos_params = {
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
        },
        stats_subcommands = { 'activity', 'contributions', 'repo' },
        web_subcommands = { 'profile', 'repo' },
    }

    return options[context] or {}
end

---Parse parameters with prefixes (e.g., "sort:", "type:", "count:")
---@param args string[]
---@param start_idx integer
---@return table<string, string>
local function parse_prefixed_params(args, start_idx)
    local params = {}
    local user_arg = ''

    for i = start_idx, #args do
        local arg = args[i]
        local prefix, value = arg:match('^(%w+):(.+)$')

        if prefix and value then
            params[prefix] = value
        else
            user_arg = arg
        end
    end

    params.user = user_arg
    return params
end

---Main completion function for Octohub command
---@param arglead string
---@param cmdline string
---@param cursorpos integer
---@return string[]
local function complete_octohub(arglead, cmdline, cursorpos)
    local args = parse_args(cmdline)
    local arg_count = #args

    if arg_count == 1 or (arg_count == 2 and arglead ~= '') then
        return filter_by_prefix(get_completion_options('subcommands'), arglead)
    elseif arg_count >= 2 then
        local subcommand = args[2]

        if subcommand == 'repos' then
            return filter_by_prefix(get_completion_options('repos_params'), arglead)
        elseif subcommand == 'stats' and (arg_count == 2 or (arg_count == 3 and arglead ~= '')) then
            return filter_by_prefix(get_completion_options('stats_subcommands'), arglead)
        elseif subcommand == 'web' and (arg_count == 2 or (arg_count == 3 and arglead ~= '')) then
            return filter_by_prefix(get_completion_options('web_subcommands'), arglead)
        end
    end

    return {}
end

---Handle repos subcommand
---@param args string[]
local function handle_repos_command(args)
    local params = parse_prefixed_params(args, 2)
    repos.show_repos(
        params.user or '',
        params.sort or config.repos.sort_by,
        params.type or config.repos.repo_type,
        params.lang or config.repos.language
    )
end

---Handle repo subcommand
---@param args string[]
local function handle_repo_command(args)
    if #args == 2 then
        repos.open_repo(args[2])
    elseif #args == 3 then
        repos.open_repo(args[3], args[2])
    else
        print('Usage: Octohub repo <name> [user]')
    end
end

---Handle stats subcommand
---@param args string[]
local function handle_stats_command(args)
    if #args == 1 then
        stats.show_all_stats('')
    elseif #args == 2 then
        local subcommand = args[2]
        if subcommand == 'activity' then
            stats.show_activity_stats('', nil)
        elseif subcommand == 'contributions' then
            stats.show_contribution_stats('')
        elseif subcommand == 'repo' then
            stats.show_repo_stats('')
        else
            stats.show_all_stats(args[2])
        end
    elseif #args >= 3 then
        local subcommand = args[2]
        if subcommand == 'activity' then
            local params = parse_prefixed_params(args, 3)
            stats.show_activity_stats(params.user or '', tonumber(params.count))
        elseif subcommand == 'contributions' then
            stats.show_contribution_stats(args[3])
        elseif subcommand == 'repo' then
            stats.show_repo_stats(args[3])
        end
    end
end

---Handle web subcommand
---@param args string[]
local function handle_web_command(args)
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
end

---Main command handler
---@param opts table
local function octohub_command(opts)
    local args = parse_args(opts.args)

    if #args == 0 then
        repos.show_repos('', config.repos.sort_by, config.repos.repo_type)
        return
    end

    local subcommand = args[1]
    local handlers = {
        repos = handle_repos_command,
        repo = handle_repo_command,
        stats = handle_stats_command,
        web = handle_web_command,
    }

    local handler = handlers[subcommand]
    if handler then
        handler(args)
    else
        print('Unknown subcommand: ' .. subcommand)
        print('Usage: Octohub <subcommand> [options]')
        print('Available subcommands: repos, repo, stats, web')
    end
end

---Add the main Octohub command
local function add_octohub_command()
    vim.api.nvim_create_user_command('Octohub', octohub_command, {
        nargs = '*',
        complete = complete_octohub,
        desc = 'GitHub integration commands',
    })
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
