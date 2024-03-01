if arg[1] and arg[1] == "testing" then
    os.setComputerLabel("*DEV* AOF Phone")
else
    os.setComputerLabel("AOF Phone")
end

local basalt = require("basalt")

function startBasalt()
    basalt.autoUpdate()
end

function exit()
    basalt.stop()
end

local mainFrame = basalt.createFrame()
    :setBackground(colors.black)

local thread = mainFrame:addThread()

os.loadAPI("json.lua")

local url = "https://aof-os.pdrewicz.site/os/client/"
if arg[1] and arg[1] == "testing" then
    url = "https://pdrewicz.site/os/"
end

local leatestVersion = http.get(url.."version.txt")
leatestVersion = tonumber(leatestVersion.readAll())

shell.run("wget", url.."start.lua","temp/startup.lua")
if fs.exists("temp/startup.lua") then
    fs.delete("startup.lua")
    fs.move("temp/startup.lua","startup.lua")
end

local programs = json.decodeFromFile("programs.json")
local settings = json.decodeFromFile("settings.json")

local version = math.floor(settings["version"]/100).."."..math.floor((settings["version"]-math.floor(settings["version"]/100)*100)/10).."."..math.floor(settings["version"]-math.floor(settings["version"]/100)*100)-math.floor((settings["version"]-math.floor(settings["version"]/100)*100)/10)*10
local updateLog = "test"






-- APPS


function showPrograms()
local showProgramsFrame = mainFrame:addFrame()
    :setPosition(1,1)
    :setSize("{parent.w}","{parent.h}")
    :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
showProgramsFrame:addButton()
    :setSize(3,1)
    :setPosition("{parent.w-4}",1)
    :setBackground(colors.red)
    :setForeground(colors.black)
    :setText("X")
    :onClick(function()
        showProgramsFrame:remove()
        thread:start(mainMenu)
    end)
for i,v in ipairs(programs["programs"]) do
    showProgramsFrame:addButton()
        :setText(v["displayName"])
        :setPosition(6,5+(i-1)*4)
        :setBackground(colors.fromBlit(v["bg"]))
        :setForeground(colors.fromBlit(v["fg"]))
        :setSize("{parent.w - 8}",3)
        :onClick(function()
            shell.openTab("programs/"..v["name"].."/"..v["path"],"aof-os")
            exit()
        end)
    showProgramsFrame:addButton()
        :setText(string.char(v["icon"]))
        :setPosition(2,5+(i-1)*4)
        :setBackground(colors.fromBlit(v["bg"]))
        :setForeground(colors.fromBlit(v["iconColor"]))
        :setSize(4,3)
        :setBorder(colors.fromBlit(v["borderColor"]),"right")
        :onClick(function()
            shell.openTab("programs/"..v["name"].."/"..v["path"],"aof-os")
            exit()
        end)
    showProgramsFrame:addButton()
        :setText("X")
        :setPosition("{parent.w - 3}",5+(i-1)*4)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setSize(1,1)
        :onClick(function()
            local tempPrograms = {programs={}}
            for j,vv in ipairs(programs["programs"]) do
                if v["name"] ~= vv["name"] then
                    tempPrograms["programs"][#tempPrograms["programs"] + 1] = vv
                end
            end
            programs = tempPrograms
            local file = fs.open("programs.json","w")
            file.write(json.encodePretty(programs))
            file.close()
            fs.delete("programs/"..v["name"])
            showProgramsFrame:remove()
            thread:start(showPrograms)
        end)
end
end








-- APP STORE



local appToDownload
local appStoreFrame
function downloadApp()
    app = appToDownload
    local out = http.get(app["url"]).readAll()
    fs.makeDir("programs/"..app["name"])
    local file = fs.open("programs/"..app["name"].."/".."startup.lua","w")
    file.write(out)
    file.close()
    programs["programs"][#programs["programs"] + 1] = {
        name = app["name"],
        displayName = app["displayName"],
        path = "startup.lua",
        bg = app["bg"],
        fg = app["fg"],
        icon = app["icon"],
        iconColor = app["iconColor"],
        borderColor = app["borderColor"],
    }
    local file = fs.open("programs.json","w")
    file.write(json.encodePretty(programs))
    file.close()
    appStoreFrame:remove()
    showAppStore()
end

function showAppStore()
    appStoreFrame = mainFrame:addFrame()
        :setPosition(1,1)
        :setSize("{parent.w}","{parent.h}")
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
    appStoreFrame:addButton()
        :setSize(3,1)
        :setPosition("{parent.w-4}",1)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("X")
        :onClick(function()
            appStoreFrame:remove()
            thread:start(mainMenu)
        end)
    local out = http.get(url.."appStore.json").readAll()
    local downloadablePrograms = json.decode(out)
    for i,v in ipairs(downloadablePrograms["apps"]) do
        local downloaded = false
        for j,vv in ipairs(programs["programs"]) do
            if v["name"] == vv["name"] then downloaded = true end
        end
        appStoreFrame:addButton()
            :setText(v["displayName"])
            :setPosition(6,5+(i-1)*4)
            :setBackground(colors.fromBlit(v["bg"]))
            :setForeground(colors.fromBlit(v["fg"]))
            :setSize("{parent.w - 8}",3)
            :onClick(function()
                if not downloaded then
                appToDownload = v
                thread:start(downloadApp)
                end
            end)
        appStoreFrame:addButton()
            :setText(string.char(v["icon"]))
            :setPosition(2,5+(i-1)*4)
            :setBackground(colors.fromBlit(v["bg"]))
            :setForeground(colors.fromBlit(v["iconColor"]))
            :setSize(4,3)
            :setBorder(colors.fromBlit(v["borderColor"]),"right")
            :onClick(function()
                if not downloaded then
                appToDownload = v
                thread:start(downloadApp)
                end
            end)
        if downloaded then
            appStoreFrame:addLabel()
                :setText("Installed")
                :setPosition(6,7+(i-1)*4)
                :setBackground(colors.green)
                :setForeground(colors.black)
                :setSize("{parent.w - 8}",1)
                :setTextAlign("center")
                :setZ(5)
        end
    end
end









-- SETTINGS




function saveSettings()
    local file = fs.open("settings.json", "w")
    file.write(json.encodePretty(settings))
    file.close()
end

function showSettings()
    settingsFrame = mainFrame:addFrame()
        :setPosition(1,1)
        :setSize("{parent.w}","{parent.h}")
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
    settingsFrame:addButton()
        :setSize(3,1)
        :setPosition("{parent.w-4}",1)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("X")
        :onClick(function()
            settingsFrame:remove()
            thread:start(mainMenu)
        end)
    settingsFrame:addLabel()
        :setSize("{parent.w-8}",3)
        :setPosition(2,3)
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :setText("\n24h clock format")
        :setTextAlign("center")
    local clockFormatCheckbox = settingsFrame:addCheckbox()
        :setSize(3,3)
        :setPosition("{parent.w-5}",3)
        :onChange(function(self)
            local value = self:getValue()
            settings["time24"] = value
            if settings["time24"] == true then
                self:setBackground(colors.green)
            else
                self:setBackground(colors.red)
            end
            thread:start(saveSettings)
        end)
        if settings["time24"] == true then
            clockFormatCheckbox:setBackground(colors.green)
        else
            clockFormatCheckbox:setBackground(colors.red)
        end
    settingsFrame:addLabel()
        :setSize("{parent.w-4}",2)
        :setPosition(2,7)
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :setText("\nTime zone")
        :setTextAlign("center")
    local timeZoneFrame = settingsFrame:addFrame()
        :setSize(12,1)
        :setPosition(14,9)
        :setBackground(colors.red)
        :setZ(1)
    local timeZone2 = settingsFrame:addInput()
    local timeZone3 = settingsFrame:addButton()
    local timeZone1 = settingsFrame:addButton()
        :setSize(12,2)
        :setPosition(2,9)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("InGame")
        :onClick(function(self)
            self:setBackground(colors.green)
            timeZone2:setBackground(colors.red)
            timeZone3:setBackground(colors.red)
            timeZoneFrame:setBackground(colors.red)
            settings["timeZone"] = "ingame"
            thread:start(saveSettings)
        end)
    timeZone2:setInputType("text")
        :setSize(3,1)
        :setPosition(18,9)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setInputLimit(2)
        :setDefaultText("...")
        :setValue("0")
        :setZ(2)
    timeZone3:setSize(12,1)
        :setPosition(14,10)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("set UTC")
        :onClick(function(self)
            local temp = tonumber(timeZone2:getValue())
            if temp and temp < 14 and temp > -12 then
                self:setBackground(colors.green)
                timeZone2:setBackground(colors.green)
                timeZoneFrame:setBackground(colors.green)
                timeZone1:setBackground(colors.red)
                settings["timeZone"] = temp
                thread:start(saveSettings)
            end
        end)
    if settings["timeZone"] == "ingame" then
        timeZone1:setBackground(colors.green)
    else
        timeZone2:setBackground(colors.green)
        timeZone3:setBackground(colors.green)
        timeZoneFrame:setBackground(colors.green)
        timeZone2:setValue(settings["timeZone"])
    end
end







-- THEMES

local themesFrame = nil
local colorPickerFrame = nil
local colorPickerType = nil

function createColorPicker()
    if colorPickerFrame then
        colorPickerFrame:remove()
    end
    local type
    if colorPickerType then
        type = colorPickerType
        colorPickerType = nil
    else
        return
    end
    local c = {
        {"0","1","2","3"},
        {"4","5","6","7"},
        {"8","9","a","b"},
        {"c","d","e","f"}}
    local temp1 = 6
    local temp2 = 8
    local temp3 = 1
    if type == "bgIconColor" then temp1 = 8 temp2 = 10 temp3 = 3 end
    colorPickerFrame = themesFrame:addFrame()
        :setSize(6,temp1)
        :setPosition("{parent.w-8}",20 - temp2)
        :setBackground(colors.gray,"+",colors.black)
        :setZ(1)
    local iconInput = nil
    for i,v in ipairs(c) do
        for j,vv in ipairs(v) do
            colorPickerFrame:addButton()
                :setSize(1,1)
                :setPosition(1+j,temp3+i)
                :setText("")
                :setBackground(colors.fromBlit(vv))
                :onClick(function()
                    settings[type] = vv
                    if iconInput and iconInput:getValue() ~= "" then
                        settings["bgIcon"] = iconInput:getValue()
                    end
                    thread:start(saveSettings)
                    themesFrame:remove()
                    thread:start(showThemes)
                end)
        end
    end
    if type == "bgIconColor" then
        iconInput = colorPickerFrame:addInput()
            :setSize(2,1)
            :setPosition(3,2)
            :setBackground(colors.black)
            :setForeground(colors.white)
            :setDefaultText("__")
            :setZ(2)
            :setInputLimit(1)
    end
end

function showThemes()
    themesFrame = mainFrame:addFrame()
        :setSize("{parent.w}","{parent.h}")
        :setPosition(1,1)
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
    themesFrame:addLabel()
        :setSize("{parent.w - 4}",3)
        :setPosition(5,3)
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
        :setForeground(colors.fromBlit(settings["fgColor"]))
        :setText("AOF-OS")
        :setFontSize(2)
    themesFrame:addButton()
        :setSize(3,1)
        :setPosition("{parent.w-4}",1)
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("X")
        :onClick(function()
            themesFrame:remove()
            thread:start(mainMenu)
        end)
    themesFrame:addButton()
        :setSize(12,3)
        :setPosition(2,8)
        :setText("Background")
        :setBackground(colors.purple)
        :setForeground(colors.black)
        :onClick(function()
            colorPickerType = "bgColor"
            thread:start(createColorPicker)
        end)
    themesFrame:addButton()
        :setSize(12,3)
        :setPosition(2,12)
        :setText("Text")
        :setBackground(colors.purple)
        :setForeground(colors.black)
        :onClick(function()
            colorPickerType = "fgColor"
            thread:start(createColorPicker)
        end)
    themesFrame:addButton()
        :setSize(12,3)
        :setPosition(2,16)
        :setText("Pattern")
        :setBackground(colors.purple)
        :setForeground(colors.black)
        :onClick(function()
            colorPickerType = "bgIconColor"
            thread:start(createColorPicker)
        end)
end







-- UPDATE


function update()
    shell.run("startup.lua","update")
    os.reboot()
end





--  MAIN MENU



function mainMenu()
    local mainMenuFrame = mainFrame:addFrame()
        :setSize("{parent.w}","{parent.h}")
        :setPosition(1,1)
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
    mainMenuFrame:addLabel()
        :setSize("{parent.w - 4}",3)
        :setPosition(5,3)
        :setBackground(colors.fromBlit(settings["bgColor"]),settings["bgIcon"],colors.fromBlit(settings["bgIconColor"]))
        :setForeground(colors.fromBlit(settings["fgColor"]))
        :setText("AOF-OS")
        :setFontSize(2)
    local timeLabel = mainMenuFrame:addLabel()
        :setSize("{parent.w-2}",1)
        :setPosition(1,1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setTextAlign("right")
        :setText(textutils.formatTime(os.time("ingame"), settings["time24"]))
    mainMenuFrame:addButton()
        :setSize(1,1)
        :setPosition(1,1)
        :setBackground(colors.gray)
        :setForeground(colors.red)
        :setText("\22")
        :onClick(function()
            os.shutdown()
        end)
    mainMenuFrame:addButton()
        :setSize(1,1)
        :setPosition(3,1)
        :setBackground(colors.gray)
        :setForeground(colors.orange)
        :setText("\7")
        :onClick(function()
            os.reboot()
        end)
    mainMenuFrame:addButton()
        :setSize(11,3)
        :setPosition(2,10)
        :setBackground(colors.cyan)
        :setText("Apps")
        :onClick(function()
            mainMenuFrame:remove()
            showPrograms()
        end)
    mainMenuFrame:addButton()
        :setSize(11,3)
        :setPosition(15,10)
        :setBackground(colors.orange)
        :setText("App Store")
        :onClick(function()
            mainMenuFrame:remove()
            thread:start(showAppStore)
        end)
    mainMenuFrame:addButton()
        :setSize(11,3)
        :setPosition(2,14)
        :setBackground(colors.lightGray)
        :setText("Settings")
        :onClick(function()
            mainMenuFrame:remove()
            thread:start(showSettings)
        end)
    mainMenuFrame:addButton()
        :setSize(11,3)
        :setPosition(15,14)
        :setBackground(colors.purple)
        :setText("Themes")
        :onClick(function()
            mainMenuFrame:remove()
            thread:start(showThemes)
        end)
    if settings["version"] and leatestVersion and settings["version"] < leatestVersion then
        mainMenuFrame:addButton()
            :setPosition(8,6)
            :setSize("{parent.w - 16}",1)
            :setBackground(colors.green)
            :setText("Update!")
            :onClick(function()
                mainMenuFrame:remove()
                thread:start(update)
            end)
    end
    if arg[1] and arg[1] == "testing" then
        mainMenuFrame:addLabel()
            :setPosition(7,8)
            :setSize("{parent.w - 14}",1)
            :setBackground(colors.red)
            :setForeground(colors.black)
            :setText("  \177DEV  MODE")
            :setTextAlign("center")
    end
    local storageDisplay = mainMenuFrame:addLabel()
        :setSize("{parent.w-4}",1)
        :setPosition(2,"{parent.h-2}")
        :setBackground(colors.green)
        :setTextAlign("center")
    while timeLabel and storageDisplay do
        if settings["timeZone"] == "ingame" then
            timeLabel:setText(textutils.formatTime(os.time("ingame"), settings["time24"]))
        else
            timeLabel:setText(textutils.formatTime(os.time("utc")+settings["timeZone"], settings["time24"]))
        end
        storageDisplay:setText(math.floor((fs.getCapacity("./")-fs.getFreeSpace("./"))/1024).."KB / "..math.floor(fs.getCapacity("./")/1024).."KB Used")
        sleep()
    end
end






-- LOADING SCREEN



function loadingScreen()
    local loadingFrame = mainFrame:addFrame()
        :setSize("{parent.w}","{parent.h}")
        :setPosition(1,1)
        :setBackground(colors.black)
    loadingFrame:addLabel()
        :setSize("{parent.w}",1)
        :setPosition(1,5)
        :setTextAlign("center")
        :setText("AOF-OS")
        :setForeground(colors.cyan)
    loadingFrame:addLabel()
        :setSize("{parent.w}",1)
        :setPosition(1,7)
        :setTextAlign("center")
        :setText("v"..version)
        :setForeground(colors.orange)
    loadingFrame:addFrame()
        :setSize(22,2)
        :setPosition(3,10)
        :setBackground(colors.gray)
    local loadingBar = loadingFrame:addFrame()
        :setSize(0,2)
        :setPosition(3,10)
        :setBackground(colors.lightGray)
    local loading = 0
    while loading < 22 do
        sleep()
        loading = loading + math.floor(math.random(8))
        if loading > 22 then loading = 22 end
        loadingBar:setSize(loading,2)
        sleep()
    end
    loadingFrame:remove()
    mainMenu()
end

parallel.waitForAny(loadingScreen,startBasalt)
