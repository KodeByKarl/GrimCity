-- Pure Lua Table & Helper compatibility functions for ESX Core

ESX.Table = {}

function ESX.SetTimeout(msec, cb)
    local id = GetGameTimer() + msec
    CreateThread(function()
        Wait(msec)
        cb()
    end)
    return id
end

function ESX.ClearTimeout(id)
end

function ESX.Await(p)
    return Citizen.Await(p)
end

function ESX.Table.SizeOf(t)
    local count = 0
    if type(t) == 'table' then
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

function ESX.Table.Set(t)
    local set = {}
    if type(t) == 'table' then
        for _, v in ipairs(t) do set[v] = true end
    end
    return set
end

function ESX.Table.IndexOf(t, value)
    if type(t) == 'table' then
        for i = 1, #t do
            if t[i] == value then return i end
        end
    end
    return -1
end

function ESX.Table.LastIndexOf(t, value)
    if type(t) == 'table' then
        for i = #t, 1, -1 do
            if t[i] == value then return i end
        end
    end
    return -1
end

function ESX.Table.Find(t, cb)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            if cb(v, k) then return v, k end
        end
    end
    return nil
end

function ESX.Table.FindIndex(t, cb)
    if type(t) == 'table' then
        for i = 1, #t do
            if cb(t[i], i) then return i end
        end
    end
    return -1
end

function ESX.Table.Filter(t, cb)
    local newTable = {}
    if type(t) == 'table' then
        for k, v in pairs(t) do
            if cb(v, k) then
                if type(k) == 'number' then
                    table.insert(newTable, v)
                else
                    newTable[k] = v
                end
            end
        end
    end
    return newTable
end

function ESX.Table.Map(t, cb)
    local newTable = {}
    if type(t) == 'table' then
        for k, v in pairs(t) do
            newTable[k] = cb(v, k)
        end
    end
    return newTable
end

function ESX.Table.Reverse(t)
    local newTable = {}
    if type(t) == 'table' then
        for i = #t, 1, -1 do
            table.insert(newTable, t[i])
        end
    end
    return newTable
end

function ESX.Table.Clone(t)
    if type(t) ~= 'table' then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = type(v) == 'table' and ESX.Table.Clone(v) or v
    end
    return copy
end

function ESX.Table.Concat(t1, t2)
    local newTable = ESX.Table.Clone(t1) or {}
    if type(t2) == 'table' then
        for i = 1, #t2 do
            table.insert(newTable, t2[i])
        end
    end
    return newTable
end

function ESX.Table.Join(t, sep)
    return table.concat(t or {}, sep or "")
end

function ESX.Table.TableContains(t, val)
    if type(t) == 'table' then
        for _, v in pairs(t) do
            if v == val then return true end
        end
    end
    return false
end

function ESX.Table.Sort(t, cb)
    if type(t) == 'table' then
        table.sort(t, cb)
    end
    return t
end

function ESX.Table.ToArray(t)
    local newTable = {}
    if type(t) == 'table' then
        for _, v in pairs(t) do
            table.insert(newTable, v)
        end
    end
    return newTable
end

function ESX.Table.Wipe(t)
    if type(t) == 'table' then
        for k in pairs(t) do
            t[k] = nil
        end
    end
    return t
end
