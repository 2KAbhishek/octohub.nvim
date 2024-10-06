local stats = require('octostats')

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

vim.api.nvim_create_user_command('OctoProfile', function(opts)
    stats.open_github_profile(opts.args)
end, { nargs = '?' })
