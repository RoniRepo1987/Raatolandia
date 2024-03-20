--***********************************************************
--**                       Lanttuchef                       **
--***********************************************************

local onHordeEventTriggerWindow = function(square, playerObj)
  local ui = LC_HET_ISHordeEventTriggerUI:new(0, 0, playerObj, square)
  ui:initialise()
  ui:addToUIManager()
end

local onDeleteEventTrigger = function(triggerName, playerObj)
  local args = {triggerName = triggerName}
  sendClientCommand(playerObj, "HordeEventTrigger", "DeleteEventTrigger", args)
end

local onActivateEventTrigger = function(triggerName, playerObj)
  local args = {triggerName = triggerName}
  sendClientCommand(playerObj, "HordeEventTrigger", "ActivateEventTrigger", args)
end

local onDeactivateEventTrigger = function(triggerName, playerObj)
  local args = {triggerName = triggerName}
  sendClientCommand(playerObj, "HordeEventTrigger", "DeactivateEventTrigger", args)
end

local onWorldContextMenu = function(player, context, worldobjects, test)
  local isSinglePlayer = getWorld():getGameMode() ~= "Multiplayer"
  if not (isClient() or isSinglePlayer) then return true end
  if test and ISWorldObjectContextMenu.Test then return true end
  if not HordeEventTrigger.modData then return true end

  local playerObj = getSpecificPlayer(player)

  if isAdmin() or isSinglePlayer then
    local square = nil

    for i,v in ipairs(worldobjects) do
        square = v:getSquare()
        break
    end

    local hordeEventTriggerOption = context:addOption(getText("ContextMenu_Horde_Event_Trigger"), worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(hordeEventTriggerOption, subMenu)
    subMenu:addOption(getText("ContextMenu_Horde_New_Event_Trigger"), square, onHordeEventTriggerWindow, playerObj)
  
    local deleteEventTriggerOption = subMenu:addOption(getText("ContextMenu_Horde_Delete_Event_Trigger"), nil, nil)
    local delEventTriggerSubmenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(deleteEventTriggerOption, delEventTriggerSubmenu)
    delEventTriggerSubmenu:addOption(getText("ContextMenu_Horde_Delete_All_Event_Triggers"), "", onDeleteEventTrigger, playerObj)

    local activateEventTriggerOption = subMenu:addOption(getText("ContextMenu_Horde_Activate_Event_Trigger"), nil, nil)
    local activateEventTriggerSubmenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(activateEventTriggerOption, activateEventTriggerSubmenu)

    activateEventTriggerSubmenu:addOption(getText("ContextMenu_Horde_Activate_All_Event_Trigger"), "", onActivateEventTrigger, playerObj)

    local deactivateEventTriggerOption = subMenu:addOption(getText("ContextMenu_Horde_Deactivate_Event_Trigger"), nil, nil)
    local deactivateEventTriggerSubmenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(deactivateEventTriggerOption, deactivateEventTriggerSubmenu)

    deactivateEventTriggerSubmenu:addOption(getText("ContextMenu_Horde_Deactivate_All_Event_Trigger"), "", onDeactivateEventTrigger, playerObj)
  
    for name,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
      if event then
        delEventTriggerSubmenu:addOptionOnTop(name, name, onDeleteEventTrigger, playerObj)

        if event.isActive then
          deactivateEventTriggerSubmenu:addOptionOnTop(name, name, onDeactivateEventTrigger, playerObj)
        else
          activateEventTriggerSubmenu:addOptionOnTop(name, name, onActivateEventTrigger, playerObj)
        end
      end
    end
  
    context:addSubMenu(subMenu, delEventTriggerSubmenu)
  elseif HordeEventTrigger.modData.trustedUsers and HordeEventTrigger.modData.trustedUsers[playerObj:getUsername()] then
    local hordeEventTriggerOption = context:addOption(getText("ContextMenu_Horde_Event_Trigger"), worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(hordeEventTriggerOption, subMenu)
    local activateEventTriggerOption = subMenu:addOption(getText("ContextMenu_Horde_Activate_Event_Trigger"), nil, nil)
    local activateEventTriggerSubmenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(activateEventTriggerOption, activateEventTriggerSubmenu)

    activateEventTriggerSubmenu:addOption(getText("ContextMenu_Horde_Activate_All_Event_Trigger"), "", onActivateEventTrigger, playerObj)

    local deactivateEventTriggerOption = subMenu:addOption(getText("ContextMenu_Horde_Deactivate_Event_Trigger"), nil, nil)
    local deactivateEventTriggerSubmenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(deactivateEventTriggerOption, deactivateEventTriggerSubmenu)

    deactivateEventTriggerSubmenu:addOption(getText("ContextMenu_Horde_Deactivate_All_Event_Trigger"), "", onDeactivateEventTrigger, playerObj)
  
    for name,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
      if event then
        if event.isActive then
          deactivateEventTriggerSubmenu:addOptionOnTop(name, name, onDeactivateEventTrigger, playerObj)
        else
          activateEventTriggerSubmenu:addOptionOnTop(name, name, onActivateEventTrigger, playerObj)
        end
      end
    end
  else
    return true
  end
end

Events.OnFillWorldObjectContextMenu.Add(onWorldContextMenu)