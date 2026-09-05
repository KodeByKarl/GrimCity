local function canIssueDocuments(xPlayer)
    if not xPlayer or not xPlayer.job then return false end
    local jobs = Config.Documents and Config.Documents.issuerJobs
    return type(jobs) == 'table' and jobs[xPlayer.job.name] == true
end

local function mapDocuments(result)
    local mapped = {}
    for i = 1, #result do
        local row = result[i]
        local thisData = json.decode(row.data)
        thisData.id = row.id
        thisData.isCopy = row.isCopy
        mapped[#mapped + 1] = thisData
    end
    return mapped
end

local function ensureDocumentTables()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `k5_documents` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `data` longtext,
            `ownerId` varchar(50),
            `isCopy` tinyint,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `k5_document_templates` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `data` longtext,
            `job` varchar(50),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end

local function seedDefaultTemplates()
    local defaults = Config.Documents and Config.Documents.DefaultTemplates
    if type(defaults) ~= 'table' then return end

    for jobName, templates in pairs(defaults) do
        if type(templates) == 'table' and #templates > 0 then
            local count = MySQL.scalar.await(
                'SELECT COUNT(*) FROM k5_document_templates WHERE job = ?',
                { jobName }
            ) or 0

            if count < 1 then
                for i = 1, #templates do
                    MySQL.insert.await(
                        'INSERT INTO k5_document_templates (data, job) VALUES (?, ?)',
                        { json.encode(templates[i]), jobName }
                    )
                end
                print(('[cfx-cs-police] Seeded %s default document templates for job "%s"'):format(#templates, jobName))
            end
        end
    end
end

CreateThread(function()
    ensureDocumentTables()
    seedDefaultTemplates()
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:getPlayerCopies', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    MySQL.Async.fetchAll(
        'SELECT id, data, isCopy FROM k5_documents WHERE ownerId = @identifier AND isCopy = "1"',
        { ['@identifier'] = xPlayer.identifier },
        function(result)
            cb(mapDocuments(result or {}))
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:getPlayerDocuments', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    MySQL.Async.fetchAll(
        'SELECT id, data, isCopy FROM k5_documents WHERE ownerId = @identifier AND isCopy = "0"',
        { ['@identifier'] = xPlayer.identifier },
        function(result)
            cb(mapDocuments(result or {}))
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:getDocumentTemplates', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    MySQL.Async.fetchAll(
        'SELECT id, data FROM k5_document_templates WHERE job = @job',
        { ['@job'] = xPlayer.job.name },
        function(result)
            local mapped = {}
            for i = 1, #(result or {}) do
                local thisData = json.decode(result[i].data)
                thisData.id = result[i].id
                mapped[#mapped + 1] = thisData
            end
            cb(mapped)
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:createTemplate', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not canIssueDocuments(xPlayer) then return cb(false) end

    MySQL.Async.insert(
        'INSERT INTO k5_document_templates (data, job) VALUES (@data, @job)',
        {
            ['@data'] = data,
            ['@job'] = xPlayer.job.name,
        },
        function(result)
            cb(result)
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:editTemplate', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not canIssueDocuments(xPlayer) then return cb(false) end

    local obj = json.decode(data)
    MySQL.Async.execute(
        'UPDATE k5_document_templates SET data = @data WHERE id = @id',
        {
            ['@data'] = data,
            ['@id'] = obj.id,
        },
        function(result)
            cb(result)
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:deleteTemplate', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not canIssueDocuments(xPlayer) then return cb(false) end

    MySQL.Async.execute(
        'DELETE FROM k5_document_templates WHERE id = @id',
        { ['@id'] = data },
        function(result)
            cb(result)
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    MySQL.Async.fetchAll(
        'SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = @identifier',
        { ['@identifier'] = xPlayer.identifier },
        function(result)
            if not result or not result[1] then
                return cb({})
            end
            cb({
                firstname = result[1].firstname,
                lastname = result[1].lastname,
                dateofbirth = result[1].dateofbirth,
                dateformat = Config.Documents.birthdateFormat,
            })
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:createDocument', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not canIssueDocuments(xPlayer) then return cb(false) end

    local docName = 'Unknown'
    if type(data) == 'string' then
        local ok, decoded = pcall(json.decode, data)
        if ok and type(decoded) == 'table' then
            docName = decoded.name or decoded.documentName or decoded.type or docName
        end
    elseif type(data) == 'table' then
        docName = data.name or data.documentName or data.type or docName
    end

    MySQL.Async.insert(
        'INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (@data, @ownerId, @isCopy)',
        {
            ['@data'] = data,
            ['@ownerId'] = xPlayer.identifier,
            ['@isCopy'] = json.decode(data).isCopy,
        },
        function(result)
            if result and PoliceLogs and PoliceLogs.Document then
                PoliceLogs.Document({
                    action = 'create',
                    src = source,
                    name = xPlayer.name,
                    identifier = xPlayer.identifier,
                    docName = docName,
                })
            end
            cb(result)
        end
    )
end)

ESX.RegisterServerCallback('cfx-cs-police:documents:deleteDocument', function(source, cb, data)
    MySQL.Async.execute(
        'DELETE FROM k5_documents WHERE id = @id',
        { ['@id'] = data },
        function(result)
            cb(result)
        end
    )
end)

RegisterNetEvent('cfx-cs-police:documents:giveCopy', function(data, targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return end

    MySQL.Async.insert(
        'INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (@data, @ownerId, @isCopy)',
        {
            ['@data'] = json.encode(data),
            ['@ownerId'] = xTarget.identifier,
            ['@isCopy'] = true,
        },
        function()
            TriggerClientEvent('cfx-cs-police:documents:copyGave', src, data.name)
            TriggerClientEvent('cfx-cs-police:documents:copyReceived', targetId, data.name)
            if PoliceLogs and PoliceLogs.Document then
                PoliceLogs.Document({
                    action = 'give',
                    src = src,
                    name = xPlayer and xPlayer.name,
                    identifier = xPlayer and xPlayer.identifier,
                    targetSrc = targetId,
                    targetName = xTarget.name,
                    targetIdentifier = xTarget.identifier,
                    docName = data and data.name or 'Unknown',
                })
            end
        end
    )
end)

RegisterNetEvent('cfx-cs-police:documents:receiveDocument', function(data, targetId)
    MySQL.Async.fetchAll(
        'SELECT data FROM k5_documents WHERE id = @docId',
        { ['@docId'] = data.docId },
        function(result)
            if result and result[1] then
                TriggerClientEvent('cfx-cs-police:documents:viewDocument', targetId, result[1])
            end
        end
    )
end)

--- Create a document for the triggering player (server API for other scripts)
RegisterNetEvent('cfx-cs-police:documents:createServerDocument', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    data.createdAt = os.date()
    MySQL.Async.insert(
        'INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (@data, @ownerId, @isCopy)',
        {
            ['@data'] = json.encode(data),
            ['@ownerId'] = xPlayer.identifier,
            ['@isCopy'] = true,
        }
    )
end)
