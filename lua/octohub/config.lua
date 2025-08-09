---@class OctohubConfig
local M = {}

---@class OctohubIcons
---@field user string
---@field user_alt string
---@field github string
---@field group string
---@field watch string
---@field location string
---@field company string
---@field info string
---@field link string
---@field calendar string
---@field repo string
---@field star string
---@field star_alt string
---@field language string
---@field contribution_icons table Icons for different contribution levels

---@class OctohubReposConfig
---@field per_user_dir boolean Whether to create a directory for each user
---@field projects_dir string Directory where repositories are cloned
---@field sort_by string Sort repositories by various params
---@field repo_type string Type of repositories to display
---@field language string Repositories language filter

---@class OctohubStatsConfig
---@field max_contributions number Max number of contributions per day to use for icon selection
---@field top_lang_count number Number of top languages to display
---@field event_count number Number of activity events to show
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

---@class OctohubConfigOptions
---@field icons OctohubIcons List of icons used by Octohub
---@field repos OctohubReposConfig Repository related config (sorting, filtering, directory structure)
---@field stats OctohubStatsConfig Stats and UI related config (icons, window size, stats toggles)
---@field cache OctohubCacheConfig Cache timeouts
---@field add_default_keybindings boolean Feature toggle for keybindings
local config = {
    icons = {
        user = ' ',
        user_alt = ' ',
        github = ' ',
        group = ' ',
        watch = ' ',
        location = ' ',
        company = ' ',
        info = ' ',
        link = ' ',
        calendar = ' ',
        repo = ' ',
        star = ' ',
        star_alt = ' ',
        language = ' ',
        contribution_icons = { '', '', '', '', '', '', '' },
    },
    repos = {
        per_user_dir = true,
        projects_dir = '~/Projects/',
        sort_by = '',
        repo_type = '',
        language = '',
    },
    stats = {
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
}

---@type OctohubConfigOptions
M.config = config

---Setup configuration with user options
---@param args OctohubConfigOptions
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

return M
