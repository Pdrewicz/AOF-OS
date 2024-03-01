local url = "https://aof-os.pdrewicz.site/os/client/"
local url2 = "https://pdrewicz.site/os/"

function downloadFile(fileUrl,fileName)
    local out = http.get(fileUrl)
    local content = nil
    if out then content = out.readAll() end
    if content then
        local file = fs.open(fileName,"w")
        file.write(content)
        file.close()
    end
end

downloadFile(url.."json.lua","json.lua")
os.loadAPI("json.lua")

if not fs.exists("settings.json") then
    local file = fs.open("settings.json","w")
    local settings = {
        bgColor = "f",
        bgIcon = "",
        bgIconColor = "f",
        fgColor = "d",
        time24 = true,
        timeZone = "ingame",
        version = 6
    }
    file.write(json.encodePretty(settings))
    file.close()
else
    local settings = json.decodeFromFile("settings.json")
    local requiredSettings = {
        {"bgColor","f"},
        {"bgIcon",""},
        {"bgIconColor","f"},
        {"fgColor","d"},
        {"time24",true},
        {"timeZone","ingame"},
        {"version",6},
        {"testing",false}
    }
    for i,v in ipairs(requiredSettings) do
        if not settings[v[1]] then
            settings[v[1]] = v[2]
        end
    end
    local file = fs.open("settings.json","w")
    file.write(json.encodePretty(settings))
    file.close()
end

local temp = json.decodeFromFile("settings.json")
local testing = temp["testing"]
if not testing then
    url2 = url
end

if testing or (arg[1] and arg[1] == "update") or not fs.exists("os.lua") then
    downloadFile(url2.."os.lua","os.lua")
    local leatestVersion = http.get(url2.."version.txt")
    if leatestVersion then 
        leatestVersion = tonumber(leatestVersion.readAll())
        local settings = json.decodeFromFile("settings.json")
        settings["version"] = leatestVersion
        local file = fs.open("settings.json","w")
        file.write(json.encodePretty(settings))
        file.close()
    end
end

downloadFile(url.."basalt.lua","basalt.lua")

if not fs.exists("programs.json") then
    local file = fs.open("programs.json","w")
    local programs = {programs={}}
    file.write(json.encodePretty(programs))
    file.close()
end

if not fs.exists("programs") then
    fs.makeDir("programs")
end

if testing then
    shell.openTab("os.lua","testing")
else
    shell.openTab("os.lua")
end
shell.exit()