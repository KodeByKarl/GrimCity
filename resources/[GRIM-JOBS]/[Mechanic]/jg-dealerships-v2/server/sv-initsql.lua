local function SplitString(text, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in string.gmatch(text, pattern) do
        local trimmed = string.gsub(match, "^%s*(.-)%s*$", "%1")
        if trimmed ~= "" then
            table.insert(result, trimmed)
        end
    end
    return result
end

local function StripBom(text)
    if text:sub(1, 3) == "\239\187\191" then
        return text:sub(4)
    end
    return text
end

local function ColumnExists(tableName, columnName)
    local result = MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
    ]], { tableName, columnName })

    return result and result > 0
end

--- Older MySQL/MariaDB do not support ADD COLUMN IF NOT EXISTS.
local function TryAddColumnCompat(statement)
    local normalized = statement:gsub("\r", "")
    if not normalized:match("^ALTER%s+TABLE") then
        return false
    end
    if not normalized:match("ADD%s+COLUMN") then
        return false
    end

    local tableName = normalized:match("ALTER%s+TABLE%s+[`\"]?([%w_]+)[`\"]?")
    local afterAdd = normalized:match("ADD%s+COLUMN%s+(.+)$")
    if not tableName or not afterAdd then
        return false
    end

    afterAdd = afterAdd:gsub("^IF%s+NOT%s+EXISTS%s+", "")
    local columnName, definition = afterAdd:match("^[`\"]?([%w_]+)[`\"]?%s+(.+)$")
    if not columnName or not definition then
        return false
    end

    if ColumnExists(tableName, columnName) then
        print(("[jg-dealerships-v2] Column `%s`.`%s` already exists, skipping"):format(tableName, columnName))
        return true
    end

    MySQL.query.await(("ALTER TABLE `%s` ADD COLUMN `%s` %s"):format(tableName, columnName, definition))
    print(("[jg-dealerships-v2] Added column `%s`.`%s`"):format(tableName, columnName))
    return true
end

function InitSQL()
    if not Config.AutoRunSQL then
        return
    end

    local success, err = pcall(function()
        local sqlFile
        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            sqlFile = "run-qb.sql"
        else
            sqlFile = "run-esx.sql"
        end

        local resourcePath = GetResourcePath(GetCurrentResourceName())
        local filePath = resourcePath .. "/install/" .. sqlFile
        local file = assert(io.open(filePath, "rb"))
        local sqlContent = StripBom(file:read("*all"))
        file:close()

        local sqlStatements = SplitString(sqlContent, ";")

        for _, statement in ipairs(sqlStatements) do
            local withoutComments = statement
                :gsub("%-%-[^\r\n]*", "")
                :gsub("\r", "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

            if withoutComments ~= "" then
                if not TryAddColumnCompat(withoutComments) then
                    MySQL.query.await(withoutComments)
                end
            end
        end
    end)

    if not success then
        print("^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file for your framework, found in the 'install' folder manually. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
        if err then
            print("^1[SQL ERROR] " .. tostring(err) .. "^0")
        end
    end
end
