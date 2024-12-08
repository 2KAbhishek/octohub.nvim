local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')
local config = require('octohub.config').config

local M = {}

M.setup = function()
    local function add_octorepos_command(name, sort_arg, type_arg)
        vim.api.nvim_create_user_command(name, function(_)
            repos.show_repos('', sort_arg, type_arg)
        end, { nargs = '?' })
    end

    vim.api.nvim_create_user_command('OctoRepos', function(opts)
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

    add_octorepos_command('OctoReposByCreated', 'create', '')
    add_octorepos_command('OctoReposByForks', 'fork', '')
    add_octorepos_command('OctoReposByIssues', 'issue', '')
    add_octorepos_command('OctoReposByLanguage', 'language', '')
    add_octorepos_command('OctoReposByName', 'name', '')
    add_octorepos_command('OctoReposByPushed', 'push', '')
    add_octorepos_command('OctoReposBySize', 'size', '')
    add_octorepos_command('OctoReposByStars', 'star', '')
    add_octorepos_command('OctoReposByUpdated', 'update', '')

    add_octorepos_command('OctoReposTypeArchived', '', 'archive')
    add_octorepos_command('OctoReposTypeForked', '', 'fork')
    add_octorepos_command('OctoReposTypePrivate', '', 'private')
    add_octorepos_command('OctoReposTypeStarred', '', 'star')
    add_octorepos_command('OctoReposTypeTemplate', '', 'template')

    vim.api.nvim_create_user_command('OctoRepo', function(opts)
        local args = vim.split(opts.args, ' ')
        if #args == 1 then
            repos.open_repo(args[1])
        elseif #args == 2 then
            repos.open_repo(args[2], args[1])
        end
    end, { nargs = '*' })

    vim.api.nvim_create_user_command('OctoStats', function(opts)
        stats.show_all_stats(opts.args)
    end, { nargs = '?' })

    vim.api.nvim_create_user_command('OctoActivityStats', function(opts)
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

    vim.api.nvim_create_user_command('OctoContributionStats', function(opts)
        stats.show_contribution_stats(opts.args)
    end, { nargs = '?' })

    vim.api.nvim_create_user_command('OctoRepoStats', function(opts)
        stats.show_repo_stats(opts.args)
    end, { nargs = '?' })

    vim.api.nvim_create_user_command('OctoRepoWeb', function(_)
        web.open_repo_web()
    end, { nargs = '?' })

    vim.api.nvim_create_user_command('OctoProfile', function(opts)
        web.open_github_profile(opts.args)
    end, { nargs = '?' })

    if config.add_default_keybindings then
        local function add_keymap(keys, cmd, desc)
            vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
        end

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
end

return M
