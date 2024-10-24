local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')
local config = require('octohub.config').config

M = {}

M.setup = function()
    vim.api.nvim_create_user_command('OctoRepos', function(opts)
        local args = vim.split(opts.args, ' ')
        local user_arg, sort_arg, type_arg = '', '', ''

        for _, arg in ipairs(args) do
            if arg:sub(1, 5) == 'sort:' then
                sort_arg = arg:sub(6)
            elseif arg:sub(1, 5) == 'type:' then
                type_arg = arg:sub(6)
            else
                user_arg = arg
            end
        end

        repos.show_repos(user_arg, sort_arg, type_arg)
    end, { nargs = '*' })

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
            if arg:sub(1, 6) == 'count:' then
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
        add_keymap('<leader>gos', ':OctoRepos sort:stars<CR>', 'Top Starred Repos')
        add_keymap('<leader>goi', ':OctoRepos sort:issues<CR>', 'Repos With Issues')
        add_keymap('<leader>gou', ':OctoRepos sort:updated<CR>', 'Recently Updated Repos')
        add_keymap('<leader>gop', ':OctoRepos type:private<CR>', 'Private Repos')
        add_keymap('<leader>gof', ':OctoRepos type:fork<CR>', 'Forked Repos')
        add_keymap('<leader>goc', ':OctoRepo<CR>', 'Open Repo')
        add_keymap('<leader>got', ':OctoStats<CR>', 'All Stats')
        add_keymap('<leader>goa', ':OctoActivityStats<CR>', 'Activity Stats')
        add_keymap('<leader>gog', ':OctoContributionStats<CR>', 'Contribution Graph')
        add_keymap('<leader>gor', ':OctoRepoStats<CR>', 'Repo Stats')
        add_keymap('<leader>goh', ':OctoProfile<CR>', 'Open GitHub Profile')
        add_keymap('<leader>gow', ':OctoRepoWeb<CR>', 'Open Repo in Browser')
    end
end

return M
