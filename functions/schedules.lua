


local Details = _G.Details
local DF = _G.DetailsFramework
local C_Timer = _G.C_Timer
local unpack = _G.unpack

--make a namespace for schedules
Details.Schedules = {}

--run a scheduled function with its payload
local triggerScheduledTick = function(tickerObject)
    local payload = tickerObject.payload
    local callback = tickerObject.callback
    return callback(unpack(payload))
end

--schedule to repeat a task with an interval of @time
function Details.Schedules:NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback
    return newTicker
end

--cancel an ongoing ticker
function Details.Schedules:CancelTicker(tickerObject)
    return tickerObject:Cancel()
end

--schedule a task with an interval of @time
function Details.Schedules:NewTimer(time, callback, ...)
    local payload = {...}
    local NewTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    NewTimer.payload = payload
    NewTimer.callback = callback
    return NewTimer
end

--schedule a task with an interval of @time without payload
function Details.Schedules:After(time, callback)
    C_Timer.After(time, callback)
end