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
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR, 'Octohub')
            return
        end

        local url = stats.html_url
        utils.open_command(url)
        utils.queue_notification('Opened GitHub profile: ' .. url, vim.log.levels.INFO, 'Octohub')
    end)
end

return M
