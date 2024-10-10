local octorepos = require('octohub.repos')
local utils = require('utils')

---@class octohub.stats
local M = {}

---@type octohub.config
M.config = require('octohub').config

---@param username string
---@param callback fun(data: table)
local function get_github_stats(username, callback)
    local command = username == '' and 'gh api user' or 'gh api users/' .. username
    utils.get_data_from_cache('user_' .. username, command, callback, M.config.user_cache_timeout)
end

---@param username string
---@param callback fun(data: table)
local function get_user_events(username, callback)
    local command = 'gh api users/' .. username .. '/events?per_page=100'
    utils.get_data_from_cache('events_' .. username, command, callback, M.config.events_cache_timeout)
end

---@param username string
---@param callback fun(data: table)
local function get_contribution_data(username, callback)
    local command = 'gh api graphql -f query=\'{user(login: "'
        .. username
        .. '") { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount } } } } } }\''
    utils.get_data_from_cache('contrib_' .. username, command, callback, M.config.contibutions_cache_timeout)
end

---@param contribution_count number
---@return string icon
local function get_icon(contribution_count)
    local index = math.min(
        math.floor(contribution_count / (M.config.max_contributions / #M.config.contrib_icons)) + 1,
        #M.config.contrib_icons
    )
    return M.config.contrib_icons[index]
end

---@param contrib_data table
---@return string
local function get_contribution_graph(contrib_data)
    local top_contributions = 0
    local calendar = contrib_data.data.user.contributionsCollection.contributionCalendar
    local graph_parts = {
        string.format(
            '\n%-4s\t %-4s\t %-4s\t %-4s\t %-4s\t %-4s\t %-4s\n',
            'Sun',
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat'
        ),
    }
    for _, week in ipairs(calendar.weeks) do
        for _, day in ipairs(week.contributionDays) do
            local contrib_count = day.contributionCount
            if contrib_count > top_contributions then
                top_contributions = contrib_count
            end
            local emoji = get_icon(contrib_count)
            local padded_count = string.format('%4d\t', day.contributionCount)
            table.insert(graph_parts, emoji .. padded_count)
        end
        table.insert(graph_parts, '\n')
    end
    table.insert(
        graph_parts,
        1,
        string.format(' Contributions\n \n Highest Contributions: %d', top_contributions)
    )
    return table.concat(graph_parts)
end

---@param events table
---@param event_count number?
---@return string
local function get_recent_activity(events, event_count)
    local activity = {}
    event_count = event_count or M.config.event_count
    table.insert(activity, ' Recent Activity\n')
    for i = 1, math.min(event_count, #events) do
        local event = events[i]
        local action = event.type:gsub('Event', '')
        local commit = event.payload
                and event.payload.commits
                and event.payload.commits[1]
                and event.payload.commits[1].message
                and '\n ' .. event.payload.commits[1].message .. '\n'
            or ''

        table.insert(
            activity,
            string.format('%s, %s, %s %s', utils.human_time(event.created_at), action, event.repo.name, commit)
        )
    end
    return table.concat(activity, '\n')
end

---@param repos table
---@return table
local function calculate_language_stats(repos)
    local lang_count = {}
    for _, repo in ipairs(repos) do
        if repo.language then
            lang_count[repo.language] = (lang_count[repo.language] or 0) + 1
        end
    end

    local lang_stats = {}
    for lang, count in pairs(lang_count) do
        table.insert(lang_stats, { language = lang, count = count })
    end

    table.sort(lang_stats, function(a, b)
        return a.count > b.count
    end)
    return lang_stats
end

---@param repos table
---@return string
local function get_repo_stats(repos)
    local total_stars = 0
    local most_starred_repo = { name = '', stars = 0 }
    for _, repo in ipairs(repos) do
        total_stars = total_stars + repo.stargazers_count
        if repo.stargazers_count > most_starred_repo.stars then
            most_starred_repo = { name = repo.name, stars = repo.stargazers_count }
        end
    end

    local lang_stats = calculate_language_stats(repos)
    local top_langs = ''
    for i = 1, math.min(M.config.top_lang_count, #lang_stats) do
        top_langs = top_langs .. string.format('\n%d. %s (%d)', i, lang_stats[i].language, lang_stats[i].count)
    end

    return string.format(
        ' Public Repos: %d\n Total Stars: %d\n Most Starred Repo: %s (%d stars)\n♥ Top Languages: %s',
        #repos,
        total_stars,
        most_starred_repo.name,
        most_starred_repo.stars,
        top_langs
    )
end

---@param stats table
---@param repos table?
---@param events table
---@param contrib_data table
---@return string
local function format_message(stats, repos, events, contrib_data)
    local messageParts = {
        string.format(
            ' User Info\n'
                .. ' Username: %s\n'
                .. ' Name: %s\n'
                .. ' Followers: %d\n'
                .. ' Following: %d\n'
                .. ' Location: %s\n'
                .. ' Company: %s\n'
                .. ' Bio: %s\n'
                .. ' Website: %s\n'
                .. ' Created At: %s\n',
            stats.login,
            stats.name,
            stats.followers,
            stats.following,
            stats.location,
            stats.company,
            stats.bio,
            stats.blog,
            utils.human_time(stats.created_at)
        ),
    }

    if repos and #repos > 0 then
        table.insert(messageParts, '\n' .. get_repo_stats(repos) .. '\n')
    end
    if M.config.show_recent_activity then
        table.insert(messageParts, '\n' .. get_recent_activity(events) .. '\n')
    end
    if M.config.show_contributions then
        table.insert(messageParts, '\n' .. get_contribution_graph(contrib_data) .. '\n')
    end
    return table.concat(messageParts)
end

---@param content string
local function show_stats_window(content)
    local stats_window_buf = nil
    local stats_window_win = nil

    vim.schedule(function()
        if not stats_window_buf or not vim.api.nvim_buf_is_valid(stats_window_buf) then
            stats_window_buf = vim.api.nvim_create_buf(false, true)
        end

        vim.api.nvim_buf_set_lines(stats_window_buf, 0, -1, true, vim.split(content, '\n'))

        if not stats_window_win or not vim.api.nvim_win_is_valid(stats_window_win) then
            local width = math.min(M.config.window_width, vim.o.columns - 4)
            local height = math.min(M.config.window_height, vim.o.lines - 4)
            stats_window_win = vim.api.nvim_open_win(stats_window_buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                col = (vim.o.columns - width) / 2,
                row = (vim.o.lines - height) / 2,
                style = 'minimal',
                border = 'rounded',
            })

            vim.api.nvim_win_set_option(stats_window_win, 'wrap', true)
            vim.api.nvim_win_set_option(stats_window_win, 'cursorline', true)
            vim.api.nvim_buf_set_keymap(stats_window_buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
        else
            vim.api.nvim_win_set_buf(stats_window_win, stats_window_buf)
        end
    end)
end

---@param username? string
function M.show_repo_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR, 'Octohub')
            return
        end

        octorepos.get_repos({ username = stats.login }, function(repos)
            local message = get_repo_stats(repos)
            show_stats_window(message)
        end)
    end)
end

---@param username string?
---@param event_count number?
function M.show_activity_stats(username, event_count)
    username = username or ''
    event_count = tonumber(event_count) or M.config.event_count
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR, 'Octohub')
            return
        end

        get_user_events(stats.login, function(events)
            local message = get_recent_activity(events, event_count)
            show_stats_window(message)
        end)
    end)
end

---@param username string?
function M.show_contribution_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR, 'Octohub')
            return
        end

        get_contribution_data(stats.login, function(contrib_data)
            local message = get_contribution_graph(contrib_data)
            show_stats_window(message)
        end)
    end)
end

---@param username string?
function M.show_all_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR, 'Octohub')
            return
        end

        if M.config.show_repo_stats then
            octorepos.get_repos({ username = stats.login }, function(repos)
                get_user_events(stats.login, function(events)
                    get_contribution_data(stats.login, function(contrib_data)
                        local message = format_message(stats, repos, events, contrib_data)
                        show_stats_window(message)
                    end)
                end)
            end)
        else
            get_user_events(stats.login, function(events)
                get_contribution_data(stats.login, function(contrib_data)
                    local message = format_message(stats, {}, events, contrib_data)
                    show_stats_window(message)
                end)
            end)
        end
    end)
end

return M
