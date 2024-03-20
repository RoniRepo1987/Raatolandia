--***********************************************************
--**                       Lanttuchef                       **
--***********************************************************

local splitString = function (input, separator)
  if separator == nil then
    separator = ","
  end
  local result = {}
  for str in string.gmatch(input, "([^"..separator.."]+)") do
     table.insert(result, str)
  end
  return result
end

local function onInitGlobalModData()
	if not isClient() then return end

	if ModData.exists("HordeEventTrigger.modData") then
		ModData.remove("HordeEventTrigger.modData")
	end

	HordeEventTrigger.modData = ModData.getOrCreate("HordeEventTrigger.modData")
  if not HordeEventTrigger.modData.eventTriggerList and not HordeEventTrigger.modData.trustedUsers then
    HordeEventTrigger.modData.eventTriggerList = {}
    HordeEventTrigger.modData.trustedUsers = {}
  end
	ModData.request("HordeEventTrigger.modData")
end

local function onReceiveGlobalModData(modDataName, data)
    if modDataName ~= "HordeEventTrigger.modData" then return end
    if not HordeEventTrigger.modData then return end

    for key, value in pairs(data) do
        HordeEventTrigger.modData[key] = value
    end
end

local function onServerCommand(module, command, arguments)
    if module ~= "HordeEventTrigger" then return end
    if command ~= "UpdateEventTriggers" then return end
    if not isClient() then return end

    if ModData.exists("HordeEventTrigger.modData") then
        ModData.remove("HordeEventTrigger.modData")
    end

    HordeEventTrigger.modData = ModData.getOrCreate("HordeEventTrigger.modData")
    ModData.request("HordeEventTrigger.modData")
end

local function onAddMessage(chatMessage, tabId)
  if not chatMessage then return end
  if not HordeEventTrigger.modData then return end

  local playerObj = getPlayer(); if not playerObj then return end
  local message = chatMessage:getText()
  local author = chatMessage:getAuthor()

  local result = splitString(message, "%s")
  local messageItems = #result

  if messageItems == 0 then return end

  local username = playerObj:getUsername()
  if username == author and messageItems > 1 then
    if result[1] == "Anna" and result[2] == "palaa!" then
      if isAdmin() or (HordeEventTrigger.modData.trustedUsers and HordeEventTrigger.modData.trustedUsers[username]) then 
        local args = {triggerName = ""}
        sendClientCommand(playerObj, "HordeEventTrigger", "ActivateEventTrigger", args)
      end
    elseif result[1] == "Rauhotu" and result[2] == "hieman!" then
      if isAdmin() or (HordeEventTrigger.modData.trustedUsers and HordeEventTrigger.modData.trustedUsers[username]) then 
        local args = {triggerName = ""}
        sendClientCommand(playerObj, "HordeEventTrigger", "DeactivateEventTrigger", args)
      end
    elseif isAdmin() and result[1] == "Ota" and result[2] == "koppi" and messageItems == 3 then
      local args = {username = result[3]}
      sendClientCommand(playerObj, "HordeEventTrigger", "AddTrustedUser", args)
    elseif isAdmin() and result[1] == "Otetaas" and result[2] == "takas" and messageItems == 3 then
      local args = {username = result[3]}
      sendClientCommand(playerObj, "HordeEventTrigger", "RemoveTrustedUser", args)
    end
  end
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnInitGlobalModData.Add(onInitGlobalModData)
Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
Events.OnAddMessage.Add(onAddMessage)