local Job = require('plenary.job')
local cache = {}
local cache_timeout = 900 -- 15 minutes
local notification_queue = {}

local M = {}

M.queue_notification = function(message, level)
    table.insert(notification_queue, { message = message, level = level })
end

M.show_notification = function(message, level)
    vim.notify(message, level, {
        title = 'GitHub Stats',
        timeout = 5000,
    })
end

local function process_notification_queue()
    vim.schedule(function()
        while #notification_queue > 0 do
            local notification = table.remove(notification_queue, 1)
            show_notification(notification.message, notification.level)
        end
    end)
end

M.async_execute = function(command, callback)
    Job:new({
        command = 'bash',
        args = { '-c', command },
        on_exit = function(j, return_val)
            local result = table.concat(j:result(), '\n')
            if return_val ~= 0 then
                queue_notification('Error executing command: ' .. command, vim.log.levels.ERROR)
                process_notification_queue()
                return
            end
            callback(result)
        end,
    }):start()
end

M.safe_json_decode = function(str)
    local success, result = pcall(vim.json.decode, str)
    if success then
        return result
    else
        M.queue_notification('Failed to parse JSON: ' .. result, vim.log.levels.ERROR)
        return nil
    end
end

M.get_data_with_cache = function(cache_key, command, callback)
    if cache[cache_key] and os.time() - cache[cache_key].time < cache_timeout then
        callback(cache[cache_key].data)
        return
    end

    async_execute(command, function(result)
        local data = safe_json_decode(result)
        if data then
            cache[cache_key] = { data = data, time = os.time() }
            callback(data)
        end
    end)
end

return M
