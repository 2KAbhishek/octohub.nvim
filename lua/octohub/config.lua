---@class Octohub
local M = {}

---@class OctohubReposConfig
---@field per_user_dir boolean Whether to create a directory for each user
---@field projects_dir string Directory where repositories are cloned
---@field sort_by string Sort repositories by various params
---@field repo_type string Type of repositories to display

---@class OctohubStatsConfig
---@field max_contributions number Max number of contributions per day to use for icon selection
---@field top_lang_count number Number of top languages to display
---@field event_count number Number of activity events to show
---@field contribution_icons table Icons for different contribution levels
---@field window_width number Width in percentage of the window to display stats
---@field window_height number Height in percentage of the window to display stats
---@field show_recent_activity boolean Whether to show recent activity
---@field show_contributions boolean Whether to show contributions
---@field show_repo_stats boolean Whether to show repository stats

---@class OctohubCacheConfig
---@field events number Time in seconds to cache events data
---@field contributions number Time in seconds to cache contributions data
---@field repos number Time in seconds to cache repositories
---@field username number Time in seconds to cache username
---@field user number Time in seconds to cache user data

---@class OctohubConfig
---@field repos OctohubReposConfig Repository related config (sorting, filtering, directory structure)
---@field stats OctohubStatsConfig Stats and UI related config (icons, window size, stats toggles)
---@field cache OctohubCacheConfig Cache timeouts
---@field add_default_keybindings boolean Feature toggle for keybindings
---@field use_new_command boolean Whether to use new Octohub command
local config = {
    repos = {
        per_user_dir = true,
        projects_dir = '~/Projects/',
        sort_by = '',
        repo_type = '',
    },
    stats = {
        contribution_icons = { '', '', '', '', '', '', '' },
        max_contributions = 50,
        top_lang_count = 5,
        event_count = 5,
        window_width = 90,
        window_height = 60,
        show_recent_activity = true,
        show_contributions = true,
        show_repo_stats = true,
    },
    cache = {
        events = 3600 * 6,
        contributions = 3600 * 6,
        repos = 3600 * 24 * 7,
        username = 3600 * 24 * 7,
        user = 3600 * 24 * 7,
    },
    add_default_keybindings = true,
    use_new_command = false,
}

---@type OctohubConfig
M.config = config

---@param args table
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

return M
