local vim = vim
local M = {}
local activity_count = 5
local octorepos_present, octorepos = pcall(require, 'octorepos')
local utils = require('octostats.utils')
local max_contributions = 50
local contrib_icons = {
    '',
    '',
    '',
    '',
    '',
    '',
    '',
}
local window_width = 100
local window_height = 50

local function get_icon(contribution_count)
    local index = math.min(math.floor(contribution_count / (max_contributions / #contrib_icons)) + 1, #contrib_icons)
    return contrib_icons[index]
end

local function get_github_stats(username, callback)
    local command = username == '' and 'gh api user' or 'gh api users/' .. username
    utils.get_data_with_cache('user_' .. username, command, callback)
end

local function get_user_events(username, callback)
    local command = 'gh api users/' .. username .. '/events?per_page=100'
    utils.get_data_with_cache('events_' .. username, command, callback)
end

local function get_contribution_data(username, callback)
    local command = 'gh api graphql -f query=\'{user(login: "'
        .. username
        .. '") { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount } } } } } }\''
    utils.get_data_with_cache('contrib_' .. username, command, callback)
end

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
    table.insert(graph_parts, 1, string.format(' Max Contributions: %d\n', top_contributions))
    return table.concat(graph_parts)
end

local function show_stats_window(content)
    local stats_window_buf = nil
    local stats_window_win = nil

    vim.schedule(function()
        if not stats_window_buf or not vim.api.nvim_buf_is_valid(stats_window_buf) then
            stats_window_buf = vim.api.nvim_create_buf(false, true)
        end

        vim.api.nvim_buf_set_lines(stats_window_buf, 0, -1, true, vim.split(content, '\n'))

        if not stats_window_win or not vim.api.nvim_win_is_valid(stats_window_win) then
            local width = math.min(window_width, vim.o.columns - 4)
            local height = math.min(window_height, vim.o.lines - 4)
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

local function get_recent_activity(events)
    local activity = {}
    for i = 1, math.min(activity_count, #events) do
        local event = events[i]
        local action = event.type:gsub('Event', ''):lower()
        table.insert(activity, string.format('%s %s %s', event.created_at, action, event.repo.name))
    end
    return table.concat(activity, '\n')
end

local function format_message(stats, repos, events, contrib_data)
    local message = string.format(
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
        stats.created_at
    )

    if repos and #repos > 0 then
        message = message .. octorepos.get_repo_stats(repos)
    end
    message = message .. string.format('\n Recent Activity\n%s\n', get_recent_activity(events))
    message = message .. string.format('\n Contributions\n%s\n', get_contribution_graph(contrib_data))
    return message
end

function M.show_github_stats(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            utils.process_notification_queue()
            return
        end

        if octorepos_present then
            octorepos.get_user_repos(stats.login, function(repos)
                get_user_events(stats.login, function(events)
                    get_contribution_data(stats.login, function(contrib_data)
                        local message = format_message(stats, repos, events, contrib_data)
                        show_stats_window(message)
                        utils.process_notification_queue()
                    end)
                end)
            end)
        else
            get_user_events(stats.login, function(events)
                get_contribution_data(stats.login, function(contrib_data)
                    local message = format_message(stats, {}, events, contrib_data)
                    show_stats_window(message)
                    utils.process_notification_queue()
                end)
            end)
        end
    end)
end

function M.open_github_profile(username)
    username = username or ''
    get_github_stats(username, function(stats)
        if stats.message then
            utils.queue_notification('Error: ' .. stats.message, vim.log.levels.ERROR)
            utils.process_notification_queue()
            return
        end

        local url = stats.html_url
        utils.open_command(url)
        utils.queue_notification('Opened GitHub profile: ' .. url, vim.log.levels.INFO)
        utils.process_notification_queue()
    end)
end

return M
