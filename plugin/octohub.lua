local repos = require('octohub.repos')
local stats = require('octohub.stats')
local web = require('octohub.web')

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
            count_arg = tonumber(arg:sub(7))
        else
            user_arg = arg
        end
    end
    stats.show_activity_stats(user_arg, count_arg)
end, { nargs = '*' })

vim.api.nvim_create_user_command('OctoContributionStats', function(opts)
    stats.show_contribution_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoRepoStats', function(opts)
    stats.show_repo_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoRepoWeb', function(opts)
    web.open_repo_web(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoProfile', function(opts)
    web.open_github_profile(opts.args)
end, { nargs = '?' })

if repos.config.add_default_keybindings then
    local function add_keymap(keys, cmd, desc)
        vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
    end

    add_keymap('<leader>goo', ':OctoRepos<CR>', 'All Repos')
    add_keymap('<leader>gof', ':OctoRepos sort:stars<CR>', 'Top Starred Repos')
    add_keymap('<leader>goi', ':OctoRepos sort:issues<CR>', 'Repos With Issues')
    add_keymap('<leader>goh', ':OctoRepos sort:updated<CR>', 'Recently Updated Repos')
    add_keymap('<leader>gop', ':OctoRepos type:private<CR>', 'Private Repos')
    add_keymap('<leader>goc', ':OctoRepos type:fork<CR>', 'Forked Repos')
    add_keymap('<leader>gor', ':OctoRepo<CR>', 'Open Repo')
    add_keymap('<leader>gow', ':OctoRepoWeb<CR>', 'Open Repo in Browser')
    add_keymap('<leader>gon', ':OctoRepoStats<CR>', 'Repo Stats')
    add_keymap('<leader>gos', ':OctoStats<CR>', 'All Stats')
    add_keymap('<leader>goa', ':OctoActivityStats count:20<CR>', 'Activity Stats')
    add_keymap('<leader>gog', ':OctoContributionStats<CR>', 'Contribution Graph')
    add_keymap('<leader>gop', ':OctoProfile<CR>', 'Open GitHub Profile')
end
