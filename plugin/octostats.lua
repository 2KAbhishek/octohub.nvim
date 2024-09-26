local stats = require('octostats')

vim.api.nvim_create_user_command('GitHubStats', function(opts)
    stats.show_github_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('GitHubProfile', function(opts)
    stats.open_github_profile(opts.args)
end, { nargs = '?' })
