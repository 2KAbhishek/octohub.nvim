local telescope = require('telescope')

local function telescope_show_repos(opts)
    require('octorepos').show_repos()
end

return telescope.register_extension({
    exports = { repos = telescope_show_repos },
})
