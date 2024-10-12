local octorepos = require('octohub.repos')
local utils = require('utils')

---@class octohub.web
local M = {}

M.open_repo_web = function()
    local open_cmd = string.format('gh repo view --web')
    vim.schedule(function()
        os.execute(open_cmd)
    end)
end

---@param username string?
function M.open_github_profile(username)
    if #username == 0 then
        octorepos.get_default_username(function(default_username)
            vim.notify('No username provided, using default username: ' .. default_username)
            username = default_username
        end)
    end
    vim.notify('Opening github profile for ' .. username)
    local url = 'https://github.com/' .. username
    utils.open_command(url)
end

return M
