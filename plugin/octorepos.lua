local repos = require('octorepos')

vim.api.nvim_create_user_command('Repos', function(opts)
    repos.show_repos(opts.args)
end, { nargs = '?' })
