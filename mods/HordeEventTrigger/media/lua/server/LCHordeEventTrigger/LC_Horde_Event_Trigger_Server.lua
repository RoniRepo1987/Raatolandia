--***********************************************************
--**                       Lanttuchef                      **
--***********************************************************

HordeEventTrigger = {}
HordeEventTrigger.modData = {}
HordeEventTrigger.modData.eventTriggerList = {}
HordeEventTrigger.modData.trustedUsers = {}

local activeTriggers = 0

local function getTableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end

local function markEventsToTrigger(triggerName)
  if not HordeEvents.eventList then return end
  for i,event in pairs(HordeEvents.eventList) do
    if event and event.attachedTriggers and event.attachedTriggers[triggerName] then
      event.triggerNow = true
    end
  end
end

local function triggerOne() 
  for i,event in pairs(HordeEvents.eventList) do
    if event and event.triggerNow then 
      local eventCopy = {}
      for key,value in pairs(event) do
        eventCopy[key] = value
      end
    
      event.triggerNow = false
      event.index = i
  
      HordeEvents.TriggerEvent(event.index)
  
      eventCopy.centralSquare.z = event.originalZ
      HordeEvents.SpawnHorde(eventCopy);

      return true
    end
  end

  return false
end

local function triggerMarkedEvents()
  if not HordeEvents.eventList then return end
  while (triggerOne()) do end
end

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

local triggerEvents = function(triggerName)
  if not HordeEvents.eventList then return end
  if getTableLength(HordeEvents.eventList) <= 0 then return end

  markEventsToTrigger(triggerName)
  triggerMarkedEvents()
end

HordeEventTrigger.UpdateClients = function ()
    print("Horde Event Trigger is now updating clients...")

    if getWorld():getGameMode() == "Multiplayer" then
        local onlinePlayers = getOnlinePlayers()

        for i = 1, onlinePlayers:size() do
            local player = onlinePlayers:get(i - 1)

            if player then
                sendServerCommand(player, "HordeEventTrigger", "UpdateEventTriggers", {})
            end
        end
    else
        local player = getPlayer()
        if player then
            sendServerCommand(player, "HordeEventTrigger", "UpdateEventTriggers", {})
        end
    end
end

HordeEventTrigger.AddEvent = function(eventValues)
    if not HordeEventTrigger.modData.eventTriggerList then return end
    if not HordeEvents.eventList then return end

    local eventIds = splitString(eventValues.eventIds)

    if #eventIds == 0 then
      return
    end

    -- Mark and detach all found events.
    for _, eventId in ipairs(eventIds) do
      local hordeEvent = HordeEvents.eventList[tonumber(eventId)]
      if hordeEvent then
        -- Detach from manual triggering by changing z value.
        if not hordeEvent.originalZ then
          hordeEvent.originalZ = hordeEvent.centralSquare.z
          hordeEvent.centralSquare.z = 1000
        end

        -- Add additional trigger name to HordeEvents structure.
        if not hordeEvent.attachedTriggers then
          hordeEvent.attachedTriggers = {}
        end

        print(string.format("Attach trigger %s to event %s", eventValues.triggerName, eventId))
        for triggerName, val in pairs(hordeEvent.attachedTriggers) do
          print(triggerName)
        end
        hordeEvent.attachedTriggers[eventValues.triggerName] = true
      end
    end

    print(string.format("Adding trigger event %s. Horde Event Ids: %s, Delay: %d", eventValues.triggerName, eventValues.eventIds, eventValues.triggerDelay))
    HordeEventTrigger.modData.eventTriggerList[eventValues.triggerName] = eventValues

    eventValues.triggerCounter = eventValues.initialTriggerDelay + eventValues.triggerDelay

    if eventValues.isActive then
      activeTriggers = activeTriggers + 1
    end

    HordeEvents.UpdateClients()
    HordeEventTrigger.UpdateClients()
end

HordeEventTrigger.DeleteEvent = function(name)
    if not HordeEventTrigger.modData.eventTriggerList then return end

    if name ~= "" then
      local event =  HordeEventTrigger.modData.eventTriggerList[name]
      if event and event.isActive then
        activeTriggers = activeTriggers - 1
      end

      HordeEventTrigger.modData.eventTriggerList[name] = nil
    else
      for key,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
        if event and event.isActive then 
          activeTriggers = activeTriggers - 1
        end
        HordeEventTrigger.modData.eventTriggerList[key] = nil
      end
    end

    HordeEventTrigger.UpdateClients()
end

HordeEventTrigger.Activate = function(name)
  if not HordeEventTrigger.modData.eventTriggerList then return end

  if name ~= "" then
    local event =  HordeEventTrigger.modData.eventTriggerList[name]
    if event and not event.isActive then
      activeTriggers = activeTriggers + 1
      event.isActive = true
    end
  else
    for key,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
      if event and not event.isActive then
        activeTriggers = activeTriggers + 1
        event.isActive = true
      end
    end
  end

  HordeEventTrigger.UpdateClients()
end

HordeEventTrigger.Deactivate = function(name)
  if not HordeEventTrigger.modData.eventTriggerList then return end

  if name ~= "" then
    local event =  HordeEventTrigger.modData.eventTriggerList[name]
    if event and event.isActive then
      activeTriggers = activeTriggers - 1
      event.isActive = false
    end
  else
    for key,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
      if event and event.isActive then
        activeTriggers = activeTriggers - 1
        event.isActive = false
      end
    end
  end

  HordeEventTrigger.UpdateClients()
end

HordeEventTrigger.AddTrustedUser = function(username)
  if not HordeEventTrigger.modData.trustedUsers then return end

  HordeEventTrigger.modData.trustedUsers[username] = true
  HordeEventTrigger.UpdateClients()
end

HordeEventTrigger.RemoveTrustedUser = function(username)
  if not HordeEventTrigger.modData.trustedUsers then return end

  HordeEventTrigger.modData.trustedUsers[username] = nil
  HordeEventTrigger.UpdateClients()
end

local function onInitGlobalModData()
    HordeEventTrigger.modData = ModData.getOrCreate("HordeEventTrigger.modData")
    if not HordeEventTrigger.modData.eventTriggerList and not HordeEventTrigger.modData.trustedUsers then
      HordeEventTrigger.modData.eventTriggerList = {}
      HordeEventTrigger.modData.trustedUsers = {}
    end
end

local function onClientCommand(module, command, playerObj, args)
  if module ~= "HordeEventTrigger" then return end

  if command == "AddEventTrigger" then
    HordeEventTrigger.AddEvent(args)
  elseif command == "DeleteEventTrigger" then
    HordeEventTrigger.DeleteEvent(args.triggerName)
  elseif command == "ActivateEventTrigger" then
    HordeEventTrigger.Activate(args.triggerName)
  elseif command == "DeactivateEventTrigger" then
    HordeEventTrigger.Deactivate(args.triggerName)
  elseif command == "AddTrustedUser" then
    HordeEventTrigger.AddTrustedUser(args.username)
  elseif command == "RemoveTrustedUser" then
    HordeEventTrigger.RemoveTrustedUser(args.username)
  end
end

local function everyMinute()
  if isClient() then return end
  if activeTriggers == 0 then return end
  print(string.format("Process Tick. active triggers: %d", activeTriggers))
  for k,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
    if event and event.isActive then
      print(string.format("Trigger: %s isActive", event.triggerName))
      if not event.triggerImmediately then
        if event.triggerCounter > 0 then
          event.triggerCounter = event.triggerCounter - 1
        end
      else
        event.triggerImmediately = false
        event.triggerCounter = 0
      end

      if event.triggerCounter == 0 then
        print(string.format("Triggering: %s", event.triggerName))
        triggerEvents(event.triggerName)

        event.triggerRounds = event.triggerRounds - 1
        if event.triggerRounds > 0 then
          event.triggerCounter = event.triggerDelay
        else
          HordeEventTrigger.DeleteEvent(event.triggerName)
        end
      end
    end
  end
end

Events.EveryOneMinute.Add(everyMinute)
Events.OnClientCommand.Add(onClientCommand)
Events.OnInitGlobalModData.Add(onInitGlobalModData)