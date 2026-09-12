local FG_RESOURCE_CANDIDATES = { 'grimbot', 'fiveguard', 'fg', 'FiveGuard' }

local M = {}

function M.resource()
    local named = GetConvar('fiveguard_resource', '')
    if named ~= '' and GetResourceState(named) == 'started' then
        return named
    end
    for i = 1, #FG_RESOURCE_CANDIDATES do
        local name = FG_RESOURCE_CANDIDATES[i]
        if GetResourceState(name) == 'started' then
            return name
        end
    end
    return nil
end

---@param src number
---@param category string
---@param perm string
---@param enable boolean
function M.set(src, category, perm, enable)
    local resource = M.resource()
    if not resource or not src then return end
    pcall(function()
        exports[resource]:SetTempPermission(src, category, perm, enable == true, false)
    end)
end

---@param src number
---@param grants table<string, string[]>
---@param enable boolean
function M.temp(src, grants, enable)
    if not grants then return end
    for category, perms in pairs(grants) do
        for i = 1, #perms do
            M.set(src, category, perms[i], enable)
        end
    end
end

return M
