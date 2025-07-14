local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')

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

---Add keymaps for legacy commands
local function add_legacy_keymaps()
    add_keymap('<leader>goo', ':OctoRepos<CR>', 'All Repos')

    add_keymap('<leader>gob', ':OctoReposBySize<CR>', 'Repos by Size')
    add_keymap('<leader>goc', ':OctoReposByCreated<CR>', 'Repos by Created')
    add_keymap('<leader>gof', ':OctoReposByForks<CR>', 'Repos by Forks')
    add_keymap('<leader>goi', ':OctoReposByIssues<CR>', 'Repos by Issues')
    add_keymap('<leader>gol', ':OctoReposByLanguage<CR>', 'Repos by Language')
    add_keymap('<leader>gos', ':OctoReposByStars<CR>', 'Repos by Stars')
    add_keymap('<leader>gou', ':OctoReposByUpdated<CR>', 'Repos by Updated')
    add_keymap('<leader>goU', ':OctoReposByPushed<CR>', 'Repos by Pushed')

    add_keymap('<leader>goA', ':OctoReposTypeArchived<CR>', 'Archived Repos')
    add_keymap('<leader>goF', ':OctoReposTypeForked<CR>', 'Forked Repos')
    add_keymap('<leader>goP', ':OctoReposTypePrivate<CR>', 'Private Repos')
    add_keymap('<leader>goS', ':OctoReposTypeStarred<CR>', 'Starred Repos')
    add_keymap('<leader>goT', ':OctoReposTypeTemplate<CR>', 'Template Repos')

    add_keymap('<leader>goa', ':OctoActivityStats<CR>', 'Activity Stats')
    add_keymap('<leader>gog', ':OctoContributionStats<CR>', 'Contribution Graph')
    add_keymap('<leader>gor', ':OctoRepoStats<CR>', 'Repo Stats')
    add_keymap('<leader>got', ':OctoStats<CR>', 'All Stats')

    add_keymap('<leader>gop', ':OctoProfile<CR>', 'Open GitHub Profile')
    add_keymap('<leader>gow', ':OctoRepoWeb<CR>', 'Open Repo in Browser')
end

--- Add commands for repos module
local function add_repo_commands()
    add_command('OctoRepos', function(opts)
        local user_arg, sort_arg, type_arg = '', '', ''
        for _, arg in ipairs(vim.split(opts.args, ' ')) do
            if arg:match('^sort:') then
                sort_arg = arg:sub(6)
            elseif arg:match('^type:') then
                type_arg = arg:sub(6)
            else
                user_arg = arg
            end
        end
        repos.show_repos(user_arg, sort_arg, type_arg)
    end, { nargs = '*' })

    add_command('OctoRepo', function(opts)
        local args = vim.split(opts.args, ' ')
        if #args == 1 then
            repos.open_repo(args[1])
        elseif #args == 2 then
            repos.open_repo(args[2], args[1])
        end
    end, { nargs = '*' })

    add_command('OctoReposByCreated', function()
        vim.cmd('OctoRepos sort:created')
    end, { nargs = '?' })
    add_command('OctoReposByForks', function()
        vim.cmd('OctoRepos sort:forks')
    end, { nargs = '?' })
    add_command('OctoReposByIssues', function()
        vim.cmd('OctoRepos sort:issues')
    end, { nargs = '?' })
    add_command('OctoReposByLanguage', function()
        vim.cmd('OctoRepos sort:language')
    end, { nargs = '?' })
    add_command('OctoReposByName', function()
        vim.cmd('OctoRepos sort:name')
    end, { nargs = '?' })
    add_command('OctoReposByPushed', function()
        vim.cmd('OctoRepos sort:pushed')
    end, { nargs = '?' })
    add_command('OctoReposBySize', function()
        vim.cmd('OctoRepos sort:size')
    end, { nargs = '?' })
    add_command('OctoReposByStars', function()
        vim.cmd('OctoRepos sort:stars')
    end, { nargs = '?' })
    add_command('OctoReposByUpdated', function()
        vim.cmd('OctoRepos sort:updated')
    end, { nargs = '?' })
    add_command('OctoReposTypeArchived', function()
        vim.cmd('OctoRepos type:archived')
    end, { nargs = '?' })
    add_command('OctoReposTypeForked', function()
        vim.cmd('OctoRepos type:forked')
    end, { nargs = '?' })
    add_command('OctoReposTypePrivate', function()
        vim.cmd('OctoRepos type:private')
    end, { nargs = '?' })
    add_command('OctoReposTypeStarred', function()
        vim.cmd('OctoRepos type:starred')
    end, { nargs = '?' })
    add_command('OctoReposTypeTemplate', function()
        vim.cmd('OctoRepos type:template')
    end, { nargs = '?' })
end

---Add commands for stats module
local function add_stat_commands()
    add_command('OctoStats', function(opts)
        stats.show_all_stats(opts.args)
    end, { nargs = '?' })

    add_command('OctoActivityStats', function(opts)
        local args = vim.split(opts.args, ' ')
        local user_arg, count_arg = '', ''
        for _, arg in ipairs(args) do
            if arg:match('^count:') then
                count_arg = arg:sub(7)
            else
                user_arg = arg
            end
        end
        stats.show_activity_stats(user_arg, tonumber(count_arg))
    end, { nargs = '*' })

    add_command('OctoContributionStats', function(opts)
        stats.show_contribution_stats(opts.args)
    end, { nargs = '?' })

    add_command('OctoRepoStats', function(opts)
        stats.show_repo_stats(opts.args)
    end, { nargs = '?' })
end

---Add commands for web module
local function add_web_commands()
    add_command('OctoRepoWeb', function(_)
        web.open_repo_web()
    end, { nargs = '?' })

    add_command('OctoProfile', function(opts)
        web.open_github_profile(opts.args)
    end, { nargs = '?' })
end

return {
    add_repo_commands = add_repo_commands,
    add_stat_commands = add_stat_commands,
    add_web_commands = add_web_commands,
    add_legacy_keymaps = add_legacy_keymaps,
}
