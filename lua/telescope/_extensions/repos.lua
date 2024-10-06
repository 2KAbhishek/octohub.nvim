local telescope = require('telescope')
local octorepos = require('octorepos')

local function telescope_show_repos(opts)
    octorepos.show_repos()
end

return telescope.register_extension({
    exports = { repos = telescope_show_repos },
})
