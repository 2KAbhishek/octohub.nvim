local repos = require('octorepos')

vim.api.nvim_create_user_command('OctoRepos', function(opts)
    repos.show_repos(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoRepoStats', function(opts)
    repos.show_repo_stats(opts.args)
end, { nargs = '?' })
