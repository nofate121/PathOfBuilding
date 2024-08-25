-- Path of Building
--
-- Class: Loadout List
-- Loadout management list control.
--
local t_insert = table.insert
local t_remove = table.remove
local m_max = math.max

local LoadoutListControlClass = newClass("LoadoutListControl", "ListControl", function(self, anchor, x, y, width, height, build)
	local loadoutlist = build:GetLoadoutList()
	self.ListControl(anchor, x, y, width, height, 16, "VERTICAL", false, loadoutlist)
	self.build = build
	self.controls.copy = new("ButtonControl", {"BOTTOM",self,"TOP"}, 0, -4, 60, 18, "Copy", function()
		-- local newLoadout = self.build:CopyLoadout(self.selValue)
		-- self:RenameLoadout(newLoadout, "Copy Loadout", true)
		self:CopyPopup(self.selValue)
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
		local newLoadout = self:RenameLoadout("", "New Loadout", true)
		self.build:SetActiveLoadout(newLoadout)
	end)
	self.controls.edit = new("ButtonControl", {"LEFT",self.controls.delete,"RIGHT"}, 4, 0, 60, 18, "Edit", function()
		-- edit loadout popup
	end)
	
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

function LoadoutListControlClass:CopyPopup(loadout)
	local controls = { }
	controls.label = new("LabelControl", nil, 0, 20, 0, 16, "^7Enter name for loadout:")
	controls.edit = new("EditControl", nil, 0, 40, 350, 20, loadout, nil, nil, 100, function(buf)
		controls.save.enabled = buf:match("%S")
	end)
	-- controls.label2 = new("LabelControl", {"LEFT", controls.edit,"RIGHT"}, 4, -20, 0, 16, "^7Loadout Id:")
	-- controls.loadoutset = new("EditControl", {"LEFT", controls.edit,"RIGHT"}, 4, 0, 80, 20, loadout:match("(%{[%w,]+%})"), nil, nil, 100, function(buf)
	-- 	controls.save.enabled = buf:match("%S")
	-- end)

	

	--controls.labelTree = new("LabelControl", nil, -100, 70, 0, 16, "Tree Set")
	local backgroundColor = 0.15

	-- name control '0' to draw it first, then other stuff on top
	controls[0] = new("SectionControl", {"TOP",controls.edit,"BOTTOM"}, -115, 20, 210, 115, "Tree Set")
	controls[0].backgroundDrawlayer = 0
	controls[0].backgroundColor = backgroundColor
	controls.checkNewTree = new("RadioButtonControl", {"TOPRIGHT",controls[0],"TOPRIGHT"}, -10, 10, 20, "Create new Tree", nil, nil, true)
	controls.checkCopyTree = new("RadioButtonControl", {"TOP",controls.checkNewTree,"BOTTOM"}, 0, 5, 20, "Copy Tree", nil, nil, false)
	controls.checkShareTree = new("RadioButtonControl", {"TOP",controls.checkCopyTree,"BOTTOM"}, 0, 5, 20, "Share Tree", nil, nil, false)
	CreateRadioButtonGroup(controls.checkNewTree, controls.checkCopyTree, controls.checkShareTree)
	controls.setListTree = new("DropDownControl", {"TOPRIGHT",controls.checkShareTree,"BOTTOMRIGHT"}, 0, 5, 190, 20, {}, nil)
	controls.setListTree.enabled = function() return not controls.checkNewTree.state end
	controls.setListTree:SetList({"Level 01-20 Tree {1}", "Level 21-40 Leveling {2}", "Level 41-60 Leveling {3}"})
	
	controls[1] = new("SectionControl", {"TOP",controls.edit,"BOTTOM"}, 115, 20, 210, 115, "Item Set")
	controls[1].backgroundDrawlayer = 0
	controls[1].backgroundColor = backgroundColor
	controls.checkNewItem = new("RadioButtonControl", {"TOPRIGHT",controls[1],"TOPRIGHT"}, -10, 10, 20, "Create new Item Set", nil, nil, true)
	controls.checkCopyItem = new("RadioButtonControl", {"TOP",controls.checkNewItem,"BOTTOM"}, 0, 5, 20, "Copy Item Set", nil, nil, false)
	controls.checkShareItem = new("RadioButtonControl", {"TOP",controls.checkCopyItem,"BOTTOM"}, 0, 5, 20, "Share Item Set", nil, nil, false)
	CreateRadioButtonGroup(controls.checkNewItem, controls.checkCopyItem, controls.checkShareItem)
	controls.setListItem = new("DropDownControl", {"TOPRIGHT",controls.checkShareItem,"BOTTOMRIGHT"}, 0, 5, 190, 20, {}, nil)
	controls.setListItem.enabled = function() return not controls.checkNewItem.state end

	controls[2] = new("SectionControl", {"TOP",controls[0],"BOTTOM"}, 0, 20, 210, 115, "Skill Set")
	controls[2].backgroundDrawlayer = 0
	controls[2].backgroundColor = backgroundColor
	controls.checkNewSkill = new("RadioButtonControl", {"TOPRIGHT",controls[2],"TOPRIGHT"}, -10, 10, 20, "Create new Skill Set", nil, nil, true)
	controls.checkCopySkill = new("RadioButtonControl", {"TOP",controls.checkNewSkill,"BOTTOM"}, 0, 5, 20, "Copy Skill Set", nil, nil, false)
	controls.checkShareSkill = new("RadioButtonControl", {"TOP",controls.checkCopySkill,"BOTTOM"}, 0, 5, 20, "Share Skill Set", nil, nil, false)
	CreateRadioButtonGroup(controls.checkNewSkill, controls.checkCopySkill, controls.checkShareSkill)
	controls.setListSkill = new("DropDownControl", {"TOPRIGHT",controls.checkShareSkill,"BOTTOMRIGHT"}, 0, 5, 190, 20, {}, nil)
	controls.setListSkill.enabled = function() return not controls.checkNewSkill.state end
		
	controls[3] = new("SectionControl", {"TOP",controls[1],"BOTTOM"}, 0, 20, 210, 115, "Config Set")
	controls[3].backgroundDrawlayer = 0
	controls[3].backgroundColor = backgroundColor
	controls.checkNewConfig = new("RadioButtonControl", {"TOPRIGHT",controls[3],"TOPRIGHT"}, -10, 10, 20, "Create new Config Set", nil, nil, true)
	controls.checkCopyConfig = new("RadioButtonControl", {"TOP",controls.checkNewConfig,"BOTTOM"}, 0, 5, 20, "Copy Config Set", nil, nil, false)
	controls.checkShareConfig = new("RadioButtonControl", {"TOP",controls.checkCopyConfig,"BOTTOM"}, 0, 5, 20, "Share Config Set", nil, nil, false)
	CreateRadioButtonGroup(controls.checkNewConfig, controls.checkCopyConfig, controls.checkShareConfig)
	controls.setListConfig = new("DropDownControl", {"TOPRIGHT",controls.checkShareConfig,"BOTTOMRIGHT"}, 0, 5, 190, 20, {}, nil)
	controls.setListConfig.enabled = function() return not controls.checkNewConfig.state end
	
	-- controls.labelitem = new("LabelControl", nil, 100, 70, 0, 16, "Item Set")

	-- controls.labelskill = new("LabelControl", nil, -100, 220, 0, 16, "Skill Set")

	-- controls.labelconfig = new("LabelControl", nil, 100, 220, 0, 16, "Config Set")


	controls.save = new("ButtonControl", nil, -45, 345, 80, 20, "Save", function()
		local newName = controls.edit.buf
		self.build.modFlag = true
		if true then
			t_insert(self.list, newName)
			self.selIndex = #self.list
			self.selValue = newName

			loadout = self.build:CopyLoadout(newName)
		else
			self.build:RenameLoadout(loadout, newName)
		end
		self.build:SyncLoadouts()
		main:ClosePopup()
	end)
	controls.save.enabled = false
	controls.cancel = new("ButtonControl", nil, 45, 345, 80, 20, "Cancel", function()
		main:ClosePopup()
	end)
	-- main:OpenPopup(370, 100, spec.title and "Rename" or "Set Name", controls, "save", "edit")
	main:OpenPopup(480, 375, "Copy Loadout", controls, "save", "edit")

	return loadout
end

function LoadoutListControlClass:GetRowValue(column, index, value)
	return (value or "Default")
end

function LoadoutListControlClass:OnSelClick(index, loadout, doubleClick)
	if doubleClick and index ~= self.build.activeLoadout then
		self.build:SetActiveLoadout(index)
	end
end

function LoadoutListControlClass:OnSelDelete(index, loadout)
	if #self.list > 1 then
		main:OpenConfirmPopup("Delete Loadout", "Are you sure you want to delete '"..(loadout or "Default").."' and all sets exclusive to it ?", "Delete", function()
			t_remove(self.list, index)
			self.build:DeleteLoadout(loadout)
		end)
	end
end

function LoadoutListControlClass:OnSelKeyDown(index, loadout, key)
	if key == "F2" then
		self:RenameSpec(loadout, "Rename Loadout")
	end
end