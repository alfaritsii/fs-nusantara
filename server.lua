local serverHash = "nDmGMyrlxK" --Key untuk akses API
local apiURL = "https://a11-4316-03.herokuapp.com/"
local version = "100"
local discordWebHook = ""


AddEventHandler('onResourceStart', function(resourceName)
    print("[FS-NUSANTARA] Test connect to API...")
    checkAPI()
end)

function checkAPI()
    PerformHttpRequest(apiURL..'test/'..serverHash, function(errorCode, resultData, resultHeaders) 
        print("[FS-NUSANTARA] API test result: "..resultData)
        if resultData == "200" then
            print("[FS-NUSANTARA] Connected to API")
            getBanData()
        else
            print("[FS-NUSANTARA] Error connecting to API")
        end
    end, "GET", json.encode(), {["Content-Type"] = "application/json"})
end

function checkUpdate()
  PerformHttpRequest(apiURL..'version/'..serverHash, function(errorCode, resultData, resultHeaders) 
      if resultData ~= version then
          print("[FS-NUSANTARA] New Version Available, Please update......")
      else
          print("[FS-NUSANTARA] System is up to date")
      end
  end, "GET", json.encode(), {["Content-Type"] = "application/json"})
end

function getBanData()
    ListBan = {}
    ResultJson = {}
    PerformHttpRequest(apiURL..'getall/'..serverHash, function(errorCode, resultData, resultHeaders)
        print("[FS-NUSANTARA] Loading ban data...")
        ResultJson = json.decode(resultData)
        for i=1, #ResultJson["data"], 1 do
            table.insert(ListBan, {
                license              = ResultJson["data"][i].license,
                ip                   = ResultJson["data"][i].ip,
                discord              = ResultJson["data"][i].discord,
                name                 = ResultJson["data"][i].name,
                date                 = ResultJson["data"][i].date,
                steam               = ResultJson["data"][i].steam,
                hwid                  = ResultJson["data"][i].hwid,
            })
        end
        Wait(5000)
        countBanData()
    end, "GET", json.encode(), {["Content-Type"] = "application/json"})
end

function countBanData()
    local count = 0
    if ListBan ~= nil then
        for k,v in pairs(ListBan) do
            count = count + 1
        end
        print("[FS-NUSANTARA] Ban data count: "..count)
        checkUpdate()
    end
end

function discordNotify(name, steam, license, ip, hwid, discord)
  local msg = {["color"] = "10552316", ["type"] = "rich", ["title"] = "Kicked blacklisted player", ["description"] =  "**Name : **" ..name .. "\n **Reason : **" .."[FS-NUSANTARA] Blacklisted Player".. "\n **IP : **||" ..ip.. "||\n **Steam : **||" .. steam .. "||\n **HWID: **||" ..hwid.. "||\n **Rockstar License : **||" .. license .. "||\n **Discord : **<@" .. discord .. ">", ["footer"] = { ["text"] = " © FS-NUSANTARA | "..os.date("%c").."" }}
    
  if name ~= "Unknown" then
    PerformHttpRequest(discordWebHook, function(err, text, headers) end, "POST", json.encode({username = "FS-NUSANTARA", embeds = {msg}}), {["Content-Type"] = "application/json"})
  end

end

AddEventHandler('playerConnecting', function (playerName,setKickReason)
    local license       = nil
    local playerip      = nil
    local playerdiscord = nil
    local hwid        = GetPlayerToken(source, 0)
    local steam       = nil
    local name  = GetPlayerName(source)
    
    for k,v in pairs(GetPlayerIdentifiers(source))do   
      if string.sub(v, 1, string.len("license:")) == "license:" then
        license = v
      elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
        steam  = v
      elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
        playerip = v
      elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
        playerdiscord = v
      end
    end
    
    if playerip == nil then
      playerip = GetPlayerEndpoint(source)
      if playerip == nil then
        playerip = 'Not found'
      end
    end
    if playerdiscord == nil then
      playerdiscord = 'Not found'
    end
    if steam == nil then
      steam = 'Not found'
    end
    if hwid == nil then
        hwid = 'Not found'
    end
    
    if (ListBan == {}) then
      Citizen.Wait(1000)
    end
     
    for i = 1, #ListBan, 1 do
      if not((tostring(ListBan[i].license)) == "Not found" ) and (tostring(ListBan[i].license)) == tostring(license) then
        discordNotify(name, steam, license, playerip, hwid, playerdiscord)
        setKickReason('[FS-NUSANTARA] Anda kena blacklist (Global)')
        CancelEvent()
      end
      if not((tostring(ListBan[i].xbl)) == "Not found") and (tostring(ListBan[i].steam)) == tostring(steam) then
        discordNotify(name, steam, license, playerip, hwid, playerdiscord)
        setKickReason('[FS-NUSANTARA] Anda kena blacklist (Global)')
        CancelEvent()
      end
      if not((tostring(ListBan[i].ip)) == "Not found") and (tostring(ListBan[i].ip))  == tostring(playerip) then
        discordNotify(name, steam, license, playerip, hwid, playerdiscord)
        setKickReason('[FS-NUSANTARA] Anda kena blacklist (Global)')
        CancelEvent()
      end
      if not((tostring(ListBan[i].discord)) == "Not found") and (tostring(ListBan[i].discord)) == tostring(playerdiscord) then
        discordNotify(name, steam, license, playerip, hwid, playerdiscord)
        setKickReason('[FS-NUSANTARA] Anda kena blacklist (Global)')
        CancelEvent()
      end
      if not((tostring(ListBan[i].hwid)) == "Not found" ) and (tostring(ListBan[i].hwid))  == tostring(hwid) then
        discordNotify(name, steam, license, playerip, hwid, playerdiscord)
        setKickReason('[FS-NUSANTARA] Anda kena blacklist (Global)')
        CancelEvent()
      end 
    end
  end)
