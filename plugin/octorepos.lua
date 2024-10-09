local repos = require('octorepos')

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

vim.api.nvim_create_user_command('OctoRepoStats', function(opts)
    repos.show_repo_stats(opts.args)
end, { nargs = '?' })

if repos.config.add_default_keybindings then
    vim.api.nvim_set_keymap('n', '<leader>goo', ':OctoRepos<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>gop', ':OctoRepos type:private<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>goh', ':OctoRepos sort:updated<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>gor', ':OctoRepo<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>gon', ':OctoRepoStats<CR>', { noremap = true, silent = true })
end
