-- Path of Building
--
-- Class: Loadout List
-- Loadout management list control.
--
local t_insert = table.insert
local t_remove = table.remove
local ipairs = ipairs
local m_max = math.max

local LoadoutListControlClass = newClass("LoadoutListControl", "ListControl", function(self, anchor, x, y, width, height, build)
	local loadoutlist = build:GetLoadoutList()
	self.ListControl(anchor, x, y, width, height, 16, "VERTICAL", false, loadoutlist)
	self.build = build
	self.controls.copy = new("ButtonControl", {"BOTTOM",self,"TOP"}, 0, -4, 60, 18, "Copy", function()
		-- local newLoadout = self.build:CopyLoadout(self.selValue)
		-- self:RenameLoadout(newLoadout, "Copy Loadout", true)
		self:LoadoutPopup(self.selValue, "copy")
	end)
	self.controls.copy.enabled = function()
		return self.selValue ~= nil
	end
	self.controls.delete = new("ButtonControl", {"LEFT",self.controls.copy,"RIGHT"}, 4, 0, 60, 18, "Delete", function()
		self:OnSelDelete(self.selIndex, self.selValue)
	end)
	self.controls.delete.enabled = function()
		return self.selValue ~= nil and #self.list > 1
	end
	self.controls.rename = new("ButtonControl", {"RIGHT",self.controls.copy,"LEFT"}, -2, 0, 60, 18, "Rename", function()
		self:RenameLoadout(self.selValue, "Rename Loadout")
	end)
	self.controls.rename.enabled = function()
		return self.selValue ~= nil
	end
	self.controls.new = new("ButtonControl", {"RIGHT",self.controls.rename,"LEFT"}, -4, 0, 60, 18, "New", function()
		--local newLoadout = self:RenameLoadout("", "New Loadout", true)
		--self.build:SetActiveLoadout(newLoadout)
		self:LoadoutPopup(self.selValue, "new")
	end)
	self.controls.edit = new("ButtonControl", {"LEFT",self.controls.delete,"RIGHT"}, 4, 0, 60, 18, "Edit", function()
		-- edit loadout popup
		self:LoadoutPopup(self.selValue, "edit")
	end)
	self.controls.edit.enabled = function()
		return self.selValue ~= nil
	end
	
end)

function LoadoutListControlClass:RenameLoadout(loadout, title, addOnName)
	local controls = { }
	controls.label = new("LabelControl", nil, 0, 20, 0, 16, "^7Enter name for loadout:")
	controls.edit = new("EditControl", nil, 0, 40, 350, 20, loadout, nil, nil, 100, function(buf)
		controls.save.enabled = buf:match("%S")
	end)
	controls.save = new("ButtonControl", nil, -45, 70, 80, 20, "Save", function()
		local newName = controls.edit.buf
		self.build.modFlag = true
		if addOnName then
			t_insert(self.list, newName)
			self.selIndex = #self.list
			self.selValue = newName

			loadout = self.build:NewLoadout(newName)
		else
			self.build:RenameLoadout(loadout, newName)
		end
		self.build:SyncLoadouts()
		main:ClosePopup()
	end)
	controls.save.enabled = false
	controls.cancel = new("ButtonControl", nil, 45, 70, 80, 20, "Cancel", function()
		main:ClosePopup()
	end)
	main:OpenPopup(370, 100, title, controls, "save", "edit")

	return loadout
end

function LoadoutListControlClass:LoadoutPopup(loadout, mode)
	local controls = { }
	controls.label = new("LabelControl", nil, 0, 20, 0, 16, "^7Enter name for loadout:")
	-- automatically select next free set link number
	local nextFreeId = self.build:GetNextLoadoutLinkId()
	local loadoutName = ""
	if mode == "new" then
		loadoutName = "New Loadout" .. " {" .. nextFreeId .. "}"
	elseif mode == "edit" then
		if loadout.linkId then
			loadoutName = loadout.setName .. " {" .. loadout.linkId .. "}"
		else
			loadoutName = loadout.setName
		end
	elseif mode == "copy" then
		loadoutName = "Copy of " .. loadout.setName .. " {" .. nextFreeId .. "}"
	end
	controls.edit = new("EditControl", nil, 0, 40, 350, 20, loadoutName, nil, nil, 100, function(buf)
		controls.save.enabled = buf:match("%S")
	end)

	controls.label2 = new("LabelControl", {"TOP",controls.edit,"BOTTOM"}, 0, 20, 0, 16, "^7Select sets for this loadout:")
	
	local backgroundColor = 0.15

	controls.setListTree = new("DropDownControl", {"TOP",controls.label2,"BOTTOM"}, 0, 10, 190, 20, nil, function(index,value)
		controls.save.enabled = true
		if value == "^7^7-----" then
			controls.setListTree:SetSel(1)
			return
		elseif value == "^7^7New Tree Set" then
			controls.checkShareTree.enabled = false
			controls.checkShareTree.state = false
		else
			controls.checkShareTree.enabled = true
		end
	end)
	local specNamesList = { }
	for _, spec in ipairs(self.build.treeTab.specList) do
		t_insert(specNamesList, (spec.title or "Default"))
	end
	t_insert(specNamesList, "^7^7-----")
	t_insert(specNamesList, "^7^7New Tree Set")
	controls.setListTree.maxDroppedWidth = 1000
	controls.setListTree.enableDroppedWidth = true
	controls.setListTree:SetList(specNamesList)
	local initialTreeIndex = loadout.treeSetId
	if mode == "new" then
		controls.setListTree:SetSel(#controls.setListTree.list, true)
	else
		controls.setListTree:SetSel(initialTreeIndex, true)
	end
	controls.setListTree.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if not controls.setListTree.dropped then
			tooltip:AddLine(16, "^7"..controls.setListTree:GetSelValue())
		end
	end
	controls.checkShareTree = new("CheckBoxControl", {"RIGHT",controls.setListTree,"LEFT"}, -5, 0, 20, "Share Set", nil, nil, false)
	controls.labelTree = new("LabelControl", {"LEFT", controls.setListTree,"RIGHT"}, 5, 0, 0, 16, "^7Tree Set")
	

	controls.setListItem = new("DropDownControl", {"TOP",controls.setListTree,"BOTTOM"}, 0, 15, 190, 20, nil, function(index,value)
		controls.save.enabled = true
		if value == "^7^7-----" then
			controls.setListItem:SetSel(1)
			return
		elseif value == "^7^7New Item Set" then
			controls.checkShareItem.enabled = false
			controls.checkShareItem.state = false
		else
			controls.checkShareItem.enabled = true
		end
	end)
	local itemNames = self.build.itemsTab:GetItemSetNamesList()
	t_insert(itemNames, "^7^7-----")
	t_insert(itemNames, "^7^7New Item Set")
	controls.setListItem.maxDroppedWidth = 1000
	controls.setListItem.enableDroppedWidth = true
	controls.setListItem:SetList(itemNames)
	local initialItemIndex = isValueInArray(self.build.itemsTab.itemSetOrderList, loadout.itemSetId)
	if mode == "new" then
		controls.setListItem:SetSel(#controls.setListItem.list, true)
	else
		controls.setListItem:SetSel(initialItemIndex, true)
	end
	controls.setListItem.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if not controls.setListItem.dropped then
			tooltip:AddLine(16, "^7"..controls.setListItem:GetSelValue())
		end
	end
	controls.checkShareItem = new("CheckBoxControl", {"RIGHT",controls.setListItem,"LEFT"}, -5, 0, 20, "Share Set", nil, nil, false)
	controls.labelItem = new("LabelControl", {"LEFT", controls.setListItem,"RIGHT"}, 5, 0, 0, 16, "^7Item Set")
	

	controls.setListSkill = new("DropDownControl", {"TOP",controls.setListItem,"BOTTOM"}, 0, 15, 190, 20, nil, function(index,value)
		controls.save.enabled = true
		if value == "^7^7-----" then
			controls.setListSkill:SetSel(1)
			return
		elseif value == "^7^7New Skill Set" then
			controls.checkShareSkill.enabled = false
			controls.checkShareSkill.state = false
		else
			controls.checkShareSkill.enabled = true
		end
	end)
	local skillNames = self.build.skillsTab:GetSkillSetNamesList()
	t_insert(skillNames, "^7^7-----")
	t_insert(skillNames, "^7^7New Skill Set")
	controls.setListSkill.maxDroppedWidth = 1000
	controls.setListSkill.enableDroppedWidth = true
	controls.setListSkill:SetList(skillNames)
	local initialSkillIndex = isValueInArray(self.build.skillsTab.skillSetOrderList, loadout.skillSetId)
	if mode == "new" then
		controls.setListSkill:SetSel(#controls.setListSkill.list, true)
	else
		controls.setListSkill:SetSel(initialSkillIndex, true)
	end
	controls.setListSkill.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if not controls.setListSkill.dropped then
			tooltip:AddLine(16, "^7"..controls.setListSkill:GetSelValue())
		end
	end
	controls.checkShareSkill = new("CheckBoxControl", {"RIGHT",controls.setListSkill,"LEFT"}, -5, 0, 20, "Share Set", nil, nil, false)
	controls.labelSkill = new("LabelControl", {"LEFT", controls.setListSkill,"RIGHT"}, 5, 0, 0, 16, "^7Skill Set")
	

	controls.setListConfig = new("DropDownControl", {"TOP",controls.setListSkill,"BOTTOM"}, 0, 15, 190, 20, nil, function(index,value)
		controls.save.enabled = true
		if value == "^7^7-----" then
			controls.setListConfig:SetSel(1)
			return
		elseif value == "^7^7New Config Set" then
			controls.checkShareConfig.enabled = false
			controls.checkShareConfig.state = false
		else
			controls.checkShareConfig.enabled = true
		end
		
		controls.checkShareConfig.enabled = false
	end)
	local configNames = self.build.configTab:GetConfigNamesList()
	t_insert(configNames, "^7^7-----")
	t_insert(configNames, "^7^7New Config Set")
	controls.setListConfig.maxDroppedWidth = 1000
	controls.setListConfig.enableDroppedWidth = true
	controls.setListConfig:SetList(configNames)
	local initialConfigIndex = isValueInArray(self.build.configTab.configSetOrderList, loadout.configSetId)
	if mode == "new" then
		controls.setListConfig:SetSel(#controls.setListConfig.list, true)
	else
		controls.setListConfig:SetSel(initialConfigIndex, true)
	end
	controls.setListConfig.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if not controls.setListConfig.dropped then
			tooltip:AddLine(16, "^7"..controls.setListConfig:GetSelValue())
		end
	end
	controls.checkShareConfig = new("CheckBoxControl", {"RIGHT",controls.setListConfig,"LEFT"}, -5, 0, 20, "Share Set", nil, nil, false)
	controls.labelConfig = new("LabelControl", {"LEFT", controls.setListConfig,"RIGHT"}, 5, 0, 0, 16, "^7Config Set")
	
	if mode == "edit" then
		controls.checkShareTree.state = true
		controls.checkShareItem.state = true
		controls.checkShareSkill.state = true
		controls.checkShareConfig.state = true
	elseif mode == "new" then
		controls.checkShareTree.enabled = false
		controls.checkShareItem.enabled = false
		controls.checkShareSkill.enabled = false
		controls.checkShareConfig.enabled = false
	end

	controls.save = new("ButtonControl", {"TOP",controls.setListConfig,"BOTTOM"}, -45, 20, 80, 20, "Save", function()
		local newName = controls.edit.buf

		if mode == "new" then
			

		elseif mode == "copy" then
			

		elseif mode == "edit" then
			-- if New Tree Set is selected (or New Item Set etc.) it won't be found in the setorderlist, 
			-- thus nil will be passed to the function call requesting to create one
			self.build:EditLoadout(loadout, newName, controls.setListTree.selIndex, 
				self.build.itemsTab.itemSetOrderList[controls.setListItem.selIndex],
				self.build.skillsTab.skillSetOrderList[controls.setListSkill.selIndex],
				self.build.configTab.configSetOrderList[controls.setListConfig.selIndex],
				controls.checkShareTree.state, controls.checkShareItem.state, controls.checkShareSkill.state, controls.checkShareConfig.state
			)
		end


		self.list = self.build:GetLoadoutList()

		main:ClosePopup()
	end)
	controls.save.enabled = false

	controls.cancel = new("ButtonControl", {"TOP",controls.setListConfig,"BOTTOM"}, 45, 20, 80, 20, "Cancel", function()
		main:ClosePopup()
	end)
	local title = ""
	if mode == "new" then
		title = "New Loadout"
	elseif mode == "copy" then
		title = "Copy Loadout"
	elseif mode == "edit" then
		title = "Edit Loadout"
	end
	main:OpenPopup(480, 290, title, controls, "save", "edit")

	return loadout
end

function LoadoutListControlClass:GetRowValue(column, index, loadout)
	local linkId = loadout.linkId
	if linkId then
		return (loadout.setName .." {"..linkId.."}" or "Default")
	else
		local tree = loadout.treeSetId
		return (loadout.setName or "Default")
	end
end

function LoadoutListControlClass:OnSelClick(index, loadout, doubleClick)
	if doubleClick and index ~= self.build.activeLoadout then
		self.build:SetActiveLoadout(index)
	end
end

function LoadoutListControlClass:OnSelDelete(index, loadout)
	if #self.list > 1 then
		main:OpenConfirmPopup("Delete Loadout", "Are you sure you want to delete '"..(loadout.setName or "Default").."' and all sets exclusive to it ?", "Delete", function()
			self.build:DeleteLoadout(loadout)
			self.list = self.build:GetLoadoutList()
		end)
	end
end

function LoadoutListControlClass:OnSelKeyDown(index, loadout, key)
	if key == "F2" then
		self:RenameSpec(loadout, "Rename Loadout")
	end
end