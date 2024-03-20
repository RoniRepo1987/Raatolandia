--**************************************************************************************
--**									 Lanttuchef									  **
--**  Considerable portion of code derived from Horde Event Mod, by BitRaven **
--**************************************************************************************

require "ISUI/ISPanelJoypad"
LC_HET_ISHordeEventTriggerUI = ISCollapsableWindow:derive("ISHordeEventTriggerUI");

local function getDefaultTriggerName()
  if not HordeEventTrigger.modData then return "" end
  local count = 0
  for i,event in pairs(HordeEventTrigger.modData.eventTriggerList) do
    count = count + 1
  end

  return string.format("Trigger %d", count + 1)
end

function LC_HET_ISHordeEventTriggerUI:onAdd()
  local triggerName = self:getTriggerName()
	local ids = self:getHordeEventIds()
	local triggerDelay = self:getTriggerDelay()
  local triggerRounds = self:getTriggerRounds()
  local initialTriggerDelay = self:getInitialTriggerDelay()
  local isActive = false
  local triggerImmediately = false

  if self.boolOptions.selected[1] then
    isActive = true
  end

  if self.boolOptions.selected[2] then
    triggerImmediately = true
  end

  print("ISHordeEventTriggerUI:onAdd")

  local args = {triggerName = triggerName, eventIds = ids, triggerDelay = triggerDelay, triggerRounds = triggerRounds, isActive = isActive, triggerImmediately = triggerImmediately, initialTriggerDelay = initialTriggerDelay}
  sendClientCommand(getPlayer(), "HordeEventTrigger", "AddEventTrigger", args)
end

function LC_HET_ISHordeEventTriggerUI:createChildren()
	local btnWid = 100
	local btnHgt = 25
	local padBottom = 0
	local y = 60
	local f = 0.8

	ISCollapsableWindow.createChildren(self)

  self.hordeEventTriggerNameLabel = ISLabel:new(10, y, 10, getText("IGUI_Horde_Event_Trigger_Name") , 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.hordeEventTriggerNameLabel)

	self.hordeEventIdsLabel = ISLabel:new(130, y, 10, getText("IGUI_Horde_Event_Ids") , 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.hordeEventIdsLabel)
	y=y+15

  self.triggerName = ISTextEntryBox:new(getDefaultTriggerName(), self.hordeEventTriggerNameLabel.x, y, 100, 20)
	self.triggerName:initialise()
	self.triggerName:instantiate()
	self:addChild(self.triggerName)

  self.hordeEventIds = ISTextEntryBox:new("1", self.hordeEventIdsLabel.x, y, 100, 20)
	self.hordeEventIds:initialise()
	self.hordeEventIds:instantiate()
	self:addChild(self.hordeEventIds)

  y=y+30

	self.triggerDelayLbl = ISLabel:new(10, y, 10, getText("IGUI_Trigger_Delay") , 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.triggerDelayLbl)
  
  self.triggerRoundsLbl = ISLabel:new(130, y, 10, getText("IGUI_Trigger_Rounds") , 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.triggerRoundsLbl)

  y=y+15

	self.triggerDelay = ISTextEntryBox:new("1", self.triggerDelayLbl.x, y, 100, 20)
	self.triggerDelay:initialise()
	self.triggerDelay:instantiate()
	self.triggerDelay:setOnlyNumbers(true)
	self:addChild(self.triggerDelay)

  self.triggerRounds = ISTextEntryBox:new("1", self.triggerRoundsLbl.x, y, 100, 20)
	self.triggerRounds:initialise()
	self.triggerRounds:instantiate()
	self.triggerRounds:setOnlyNumbers(true)
	self:addChild(self.triggerRounds)

  y=y+30

  self.initialTriggerDelayLbl = ISLabel:new(10, y, 10, getText("IGUI_Trigger_Initial_Delay") , 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.initialTriggerDelayLbl)

  y=y+15

  self.initialTriggerDelay = ISTextEntryBox:new("0", self.initialTriggerDelayLbl.x, y, 100, 20)
	self.initialTriggerDelay:initialise()
	self.initialTriggerDelay:instantiate()
	self.initialTriggerDelay:setOnlyNumbers(true)
	self:addChild(self.initialTriggerDelay)

  y=y+30

  self.boolOptions = ISTickBox:new(10, y, 200, 20, "", self, LC_HET_ISHordeEventTriggerUI.onBoolOptionsChange)
	self.boolOptions:initialise()
	self:addChild(self.boolOptions)
	self.boolOptions:addOption("Is Active")
	self.boolOptions:addOption("Trigger Immediately")

  y=y+30

	self.add = ISButton:new(10, self:getHeight() - padBottom - btnHgt - 22, btnWid*f, btnHgt, getText("IGUI_Add"), self, LC_HET_ISHordeEventTriggerUI.onAdd)
	self.add.anchorTop = false
	self.add.anchorBottom = true
	self.add:initialise()
	self.add:instantiate()
	self.add.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.add)

	self.closeButton2 = ISButton:new(self.width - btnWid*f - 10, self.add.y, btnWid*f, btnHgt, getText("UI_Close"), self, LC_HET_ISHordeEventTriggerUI.close)
	self.closeButton2.anchorTop = false
	self.closeButton2.anchorBottom = true
	self.closeButton2:initialise()
	self.closeButton2:instantiate()
	self.closeButton2.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.closeButton2)
end

function LC_HET_ISHordeEventTriggerUI:getTriggerName()
	return self.triggerName:getInternalText()
end

function LC_HET_ISHordeEventTriggerUI:getHordeEventIds()
	return self.hordeEventIds:getInternalText()
end

function LC_HET_ISHordeEventTriggerUI:getTriggerDelay()
	local triggerDelay = self.triggerDelay:getInternalText()
	return (tonumber(triggerDelay) or 1)
end

function LC_HET_ISHordeEventTriggerUI:getInitialTriggerDelay()
	local initialTriggerDelay = self.initialTriggerDelay:getInternalText()
	return (tonumber(initialTriggerDelay) or 0)
end

function LC_HET_ISHordeEventTriggerUI:getTriggerRounds()
	local triggerRounds = self.triggerRounds:getInternalText()
	return (tonumber(triggerRounds) or 1)
end

function LC_HET_ISHordeEventTriggerUI:onBoolOptionsChange(index, selected)
  self.boolOptions.selected[index] = selected
end

function LC_HET_ISHordeEventTriggerUI:prerender()
	ISCollapsableWindow.prerender(self)
end

function LC_HET_ISHordeEventTriggerUI:render()
	ISCollapsableWindow.render(self)
end

function LC_HET_ISHordeEventTriggerUI:close()
	self:setVisible(false)
	self:removeFromUIManager()
end

function LC_HET_ISHordeEventTriggerUI:new(x, y, character, square)
	local width = 250
	local height = 300
	local o = ISCollapsableWindow.new(self, x, y, width, height)
	o.playerNum = character:getPlayerNum()
	if y == 0 then
		o.y = getPlayerScreenTop(o.playerNum) + (getPlayerScreenHeight(o.playerNum) - height) / 2
		o:setY(o.y)
	end
	if x == 0 then
		o.x = getPlayerScreenLeft(o.playerNum) + (getPlayerScreenWidth(o.playerNum) - width) / 2
		o:setX(o.x)
	end
	o.width = width
	o.height = height
	o.chr = character
	o.moveWithMouse = true
	o.selectX = square:getX()
	o.selectY = square:getY()
	o.selectZ = square:getZ()
	o.anchorLeft = true
	o.anchorRight = true
	o.anchorTop = true
	o.anchorBottom = true
	return o
end
