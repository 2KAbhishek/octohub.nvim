---@class octohub
local M = {}

---@class octohub.config
---@field contribution_icons table : Table of icons to use for contributions, can be any length
---@field per_user_dir boolean : Whether to create a directory for each user
---@field projects_dir string : Directory where repositories are cloned
---@field sort_repos_by string : Sort repositories by various params
---@field repo_type string : Type of repositories to display
---@field max_contributions number : Max number of contributions per day to use for icon selection
---@field top_lang_count number : Number of top languages to display
---@field event_count number : Number of activity events to show
---@field window_width number : Width in percentage of the window to display stats
---@field window_height number :Height in percentage of the window to display stats
---@field show_recent_activity boolean : Whether to show recent activity
---@field show_contributions boolean : Whether to show contributions
---@field show_repo_stats boolean : Whether to show repository stats
---@field repo_cache_timeout number : Time in seconds to cache repositories
---@field username_cache_timeout number : Time in seconds to cache username
---@field events_cache_timeout number : Time in seconds to cache events data
---@field contributions_cache_timeout number : Time in seconds to contributions data
---@field user_cache_timeout number : Time in seconds to cache user data
---@field add_default_keybindings boolean : Whether to add default keybindings
---@field use_new_command boolean : Whether to use new Octohub command
local config = {
    contribution_icons = { '', '', '', '', '', '', '' },
    per_user_dir = true,
    projects_dir = '~/Projects/',
    sort_repos_by = '',
    repo_type = '',
    max_contributions = 50,
    top_lang_count = 5,
    event_count = 5,
    window_width = 90,
    window_height = 60,
    show_recent_activity = true,
    show_contributions = true,
    show_repo_stats = true,
    events_cache_timeout = 3600 * 6,
    contibutions_cache_timeout = 3600 * 6,
    repo_cache_timeout = 3600 * 24 * 7,
    username_cache_timeout = 3600 * 24 * 7,
    user_cache_timeout = 3600 * 24 * 7,
    add_default_keybindings = true,
    use_new_command = false,
}

---@type octohub.config
M.config = config

---@param args octohub.config
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

return M
