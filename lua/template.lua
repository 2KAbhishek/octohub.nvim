-- main module file
local template_module = require('template.module')

---@class Config
---@field name string
local config = {
    name = 'World!',
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

M.hello = function()
    return template_module.greet(M.config.name)
end

return M
