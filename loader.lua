local scriptURL = "https://raw.githubusercontent.com/yourusername/utility-script/main/script.lua"
local versionURL = "https://raw.githubusercontent.com/yourusername/utility-script/main/version.txt"

local currentVersion = "1.0"

local function getLatestVersion()
    local success, result = pcall(function()
        return game:HttpGet(versionURL)
    end)
    if success then
        return result:gsub("%s+", "") -- убираем пробелы и переносы
    end
    return currentVersion
end

local latest = getLatestVersion()
if latest ~= currentVersion then
    warn("Обновление найдено! Загружаем версию " .. latest)
else
    print("Скрипт актуален (v" .. currentVersion .. ")")
end

loadstring(game:HttpGet(scriptURL))()