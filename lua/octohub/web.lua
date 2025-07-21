local octorepos = require('octohub.repos')
local shell = require('utils.shell')

---@class OctohubWeb
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
            username = default_username
        end)
    end
    local url = 'https://github.com/' .. username
    shell.open_command(url)
end

return M
