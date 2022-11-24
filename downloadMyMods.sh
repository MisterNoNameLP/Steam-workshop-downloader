#!/bin/lua
local version = "v0.2"

print("Running mod downloader " .. version)

local installPath = "/home/noname/games/rimworld/modding/mods"
local appID = "294100"
local downloadScriptName = "modDownloadScript.sh"
local modlistHTMLFile = "modlist.html"

local source = io.open(modlistHTMLFile, "r"):read("*a")
local ids = {}

if io.open(downloadScriptName, "r") ~= nil then
    print("ERROR: download script file already exitsts!")
    os.exit(1)
end

local downloadScript = io.open(downloadScriptName, "w")

for line in source:gmatch("[^\n]+") do
    --print(line)
    local found, idStartPos = line:find("steamcommunity.com/sharedfiles/filedetails/(?)id=")

    if found ~= nil then
        local _, idEndPos = line:find("%d+")
        line = line:sub(idStartPos + 1, idEndPos)

        if tonumber(line) ~= nil then
            ids[line] = true
        else
            print("ERROR: suspicious id: " .. line)
        end
    end
end

downloadScript:write("#!/bin/bash \nsteamcmd +force_install_dir " .. installPath .. " +login anonymous ")

for id in pairs(ids) do
    downloadScript:write("+workshop_download_item " .. appID .. " " .. id .. "validate ")
end

downloadScript:write("+quit ")
downloadScript:close()

os.execute("chmod +x " .. downloadScriptName)
os.execute("./" .. downloadScriptName)
os.execute("rm " .. downloadScriptName)
os.exit(0)
