local File = CS.System.IO.File
local Directory = CS.System.IO.Directory

local function findElement(arr, s)
    for i, str in ipairs(arr) do
        if string.find(str, s) then
            return { line = i, text = str }
        end
    end
    return nil
end

local function findFirstFileWithExtension(directory, extension)
    local files = Directory.GetFiles(directory, "*" .. extension)

    if files[0] then
        return files[0]
    else
        return nil
    end
end

local function modifyBeat()
    local MusicManager = CS.UnityEngine.GameObject.Find("MusicManager")
    local AudioSource = MusicManager:GetComponent(typeof(CS.UnityEngine.AudioSource))
    local seconds = AudioSource.clip.length
    
    local impl = "#LASTSECONDHINT:" .. (math.ceil(seconds)) .. ";"
    
    local filePath = findFirstFileWithExtension(SONGMAN:GetSongDir(), '.dl')

    if not filePath then return end

    local fileContents = File.ReadAllText(filePath)

    local lines = {}
    for line in fileContents:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local modded = findElement(lines, '#W_MOD_SAVED;')

    if not modded then
        local lsh = findElement(lines, "#LASTSECONDHINT")

        if lsh then
            lines[lsh.line] = impl
            lines[#lines + 1] = "#W_MOD_SAVED;"
        else
            -- If #LASTSECONDHINT is not found, add it at a new index

            local difficulties = findElement(lines, '#DIFFICULTIES')
            if difficulties then
                table.insert(lines, difficulties.line + 1, impl)
                lines[#lines + 1] = "#W_MOD_SAVED;"
            end
        end

        local result = table.concat(lines, "\n")
        File.WriteAllText(filePath, result)

        SCREENMAN:SystemMessage("[N] LASTSECONDHINT mod applied. Please restart the chart.")
    end
end

function start()
    modifyBeat()
end
