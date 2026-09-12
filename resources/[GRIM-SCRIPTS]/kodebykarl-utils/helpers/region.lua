--[[
    Region function checks (routing-bucket instances via kodebykarl-ui).
]]

local Region = {}
local UI = 'kodebykarl-ui'

function Region.Allowed(fn, src)
    if type(fn) ~= 'string' or fn == '' then return false end
    if GetResourceState(UI) ~= 'started' then return false end

    if IsDuplicityVersion() then
        src = tonumber(src)
        if not src or src < 1 then return false end
        local ok, allowed = pcall(function()
            return exports[UI]:PlayerHasFunction(src, fn)
        end)
        return ok and allowed == true
    end

    local ok, allowed = pcall(function()
        return exports[UI]:HasFunction(fn)
    end)
    return ok and allowed == true
end

function Region.Message(fn)
    if GetResourceState(UI) ~= 'started' then
        return 'This is only available on another region. Open Control Center (F5) → Regions.'
    end
    local ok, msg = pcall(function()
        return exports[UI]:WrongServerMessage(fn)
    end)
    if ok and type(msg) == 'string' and msg ~= '' then
        return msg
    end
    return 'This is only available on another region. Open Control Center (F5) → Regions.'
end

return Region
