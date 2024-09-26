---@class CustomModule
local M = {}

---@return string
M.greet = function(name)
    M.show_notification('Hello ' .. name)
    return 'Hello ' .. name
end

M.show_notification = function(message)
    vim.notify(message, vim.log.levels.INFO, {
        title = 'Template',
        timeout = 5000,
    })
end

return M
