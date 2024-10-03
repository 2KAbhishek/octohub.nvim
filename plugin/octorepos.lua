local repos = require('octorepos')

vim.api.nvim_create_user_command('OctoRepos', function(opts)
    repos.show_repos(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OctoRepo', function(opts)
    local args = vim.split(opts.args, ' ')
    if #args == 1 then
        repos.open_repo(args[1])
    elseif #args == 2 then
        repos.open_repo(args[2], args[1])
    end
end, { nargs = '*' })

vim.api.nvim_create_user_command('OctoRepoStats', function(opts)
    repos.show_repo_stats(opts.args)
end, { nargs = '?' })
