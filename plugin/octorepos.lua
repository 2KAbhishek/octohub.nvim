local repos = require('octorepos')

vim.api.nvim_create_user_command('GitHubStats', function(opts)
    repos.show_github_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('GitHubProfile', function(opts)
    repos.open_github_profile(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('Repos', function(opts)
    repos.show_repos(opts.args)
end, { nargs = '?' })
