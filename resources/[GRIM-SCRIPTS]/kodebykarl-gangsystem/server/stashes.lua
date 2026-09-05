GangStashes = GangStashes or {}

local registered = {}

local function StashId(kind, gangId)
    return ('gang_%s_%s'):format(gangId, kind)
end

function GangStashes.RegisterAll()
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        local bossId = StashId('boss', g.id)
        local publicId = StashId('public', g.id)
        local personalId = StashId('personal', g.id)

        if not registered[bossId] then
            exports.ox_inventory:RegisterStash(
                bossId,
                ('%s %s'):format(g.label, Config.Stash.Boss.label),
                Config.Stash.Boss.slots,
                Config.Stash.Boss.weight,
                false
            )
            registered[bossId] = true
        end

        if not registered[publicId] then
            exports.ox_inventory:RegisterStash(
                publicId,
                ('%s %s'):format(g.label, Config.Stash.Public.label),
                Config.Stash.Public.slots,
                Config.Stash.Public.weight,
                false
            )
            registered[publicId] = true
        end

        if not registered[personalId] then
            exports.ox_inventory:RegisterStash(
                personalId,
                ('%s %s'):format(g.label, Config.Stash.Personal.label),
                Config.Stash.Personal.slots,
                Config.Stash.Personal.weight,
                true -- unique per player
            )
            registered[personalId] = true
        end
    end
end

local function SameGang(src, gangId)
    local gang = GangMembership.GetPlayerGang(src)
    return gang and gang.name == gangId
end

RegisterNetEvent('kodebykarl-gangsystem:server:openStash', function(gangId, kind)
    local src = source
    if type(gangId) ~= 'string' or type(kind) ~= 'string' then return end
    if not Config.GetGang(gangId) then return end
    if not SameGang(src, gangId) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'GANG',
            description = 'You are not a member of this gang.',
            type = 'error',
        })
    end

    local gang = GangMembership.GetPlayerGang(src)
    if not gang then return end

    if kind == 'boss' then
        if (gang.grade or 0) < (Config.BossGradeMin or 3) then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = 'GANG',
                description = 'Boss stash is for bosses only.',
                type = 'error',
            })
        end
        exports.ox_inventory:forceOpenInventory(src, 'stash', StashId('boss', gangId))
    elseif kind == 'public' then
        exports.ox_inventory:forceOpenInventory(src, 'stash', StashId('public', gangId))
    elseif kind == 'personal' then
        exports.ox_inventory:forceOpenInventory(src, 'stash', StashId('personal', gangId))
    end
end)
