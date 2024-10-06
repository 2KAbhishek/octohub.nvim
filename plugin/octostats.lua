local stats = require('octostats')

vim.api.nvim_create_user_command('OctoStats', function(opts)
    stats.show_all_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoActivityStats', function(opts)
    stats.show_activity_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoContributionStats', function(opts)
    stats.show_contribution_stats(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoProfile', function(opts)
    stats.open_github_profile(opts.args)
end, { nargs = '?' })
