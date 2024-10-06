local repos = require('octorepos')

vim.api.nvim_create_user_command('OctoRepos', function(opts)
    local args = vim.split(opts.args, ' ')
    local user_arg, sort_arg = '', ''

    if #args >= 1 then
        if args[1]:sub(1, 5) == 'sort:' then
            sort_arg = args[1]:sub(6)
        else
            user_arg = args[1]
        end
    end

    if #args == 2 and args[2]:sub(1, 5) == 'sort:' then
        sort_arg = args[2]:sub(6)
    end

    repos.show_repos(user_arg, sort_arg)
end, { nargs = '*' })

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
