-- Path of Building
--
-- Class: Loadout List
-- Loadout management list control.
--
local t_insert = table.insert
local t_remove = table.remove
local m_max = math.max

local PassiveSpecListClass = newClass("LoadoutListControl", "ListControl", function(self, anchor, x, y, width, height, build)
	local loadoutlist = build:GetLoadoutList()
	self.ListControl(anchor, x, y, width, height, 16, "VERTICAL", true, loadoutlist)
	self.build = build
	self.controls.copy = new("ButtonControl", {"BOTTOM",self,"TOP"}, 0, -4, 60, 18, "Copy", function()
		local newLoadout = self.build:CopyLoadout(self.selIndex)
		self:RenameLoadout(newLoadout, "Copy Loadout", true)
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
		local newLoadout = self.build:NewLoadout(self.selIndex)
		self:RenameLoadout(newLoadout, "New Tree", true)
		-- new loadout popup
	end)
	self.controls.edit = new("ButtonControl", {"LEFT",self.controls.delete,"RIGHT"}, 4, 0, 60, 18, "Edit", function()
		-- edit loadout popup
	end)
	
	--self:UpdateItemsTabPassiveTreeDropdown()

end)

function PassiveSpecListClass:RenameLoadout(spec, title, addOnName)
	local controls = { }
	controls.label = new("LabelControl", nil, 0, 20, 0, 16, "^7Enter name for this passive tree:")
	controls.edit = new("EditControl", nil, 0, 40, 350, 20, spec.title, nil, nil, 100, function(buf)
		controls.save.enabled = buf:match("%S")
	end)
	controls.save = new("ButtonControl", nil, -45, 70, 80, 20, "Save", function()
		spec.title = controls.edit.buf
		self.treeTab.modFlag = true
		if addOnName then
			t_insert(self.list, spec)
			self.selIndex = #self.list
			self.selValue = spec
		end
		self:UpdateItemsTabPassiveTreeDropdown()
		self.treeTab.build:SyncLoadouts()
		main:ClosePopup()
	end)
	controls.save.enabled = false
	controls.cancel = new("ButtonControl", nil, 45, 70, 80, 20, "Cancel", function()
		main:ClosePopup()
	end)
	-- main:OpenPopup(370, 100, spec.title and "Rename" or "Set Name", controls, "save", "edit")
	main:OpenPopup(370, 100, title, controls, "save", "edit")
end

function PassiveSpecListClass:GetRowValue(column, index, value)
	return (value or "Default")
end

function PassiveSpecListClass:OnOrderChange()
	-- self.treeTab.activeSpec = isValueInArray(self.list, self.treeTab.build.spec)
	-- self.treeTab.modFlag = true
	-- self:UpdateItemsTabPassiveTreeDropdown()
	-- self.treeTab.build:SyncLoadouts()
end

function PassiveSpecListClass:OnSelClick(index, loadout, doubleClick)
	if doubleClick and index ~= self.build.activeLoadout then
		self.build:SetActiveLoadout(index)
	end
end

function PassiveSpecListClass:OnSelDelete(index, loadout)
	-- if #self.list > 1 then
	-- 	main:OpenConfirmPopup("Delete Tree", "Are you sure you want to delete '"..(spec.title or "Default").."'?", "Delete", function()
	-- 		t_remove(self.list, index)
	-- 		self.selIndex = nil
	-- 		self.selValue = nil
	-- 		if index == self.treeTab.activeSpec then 
	-- 			self.treeTab:SetActiveSpec(m_max(1, index - 1))
	-- 		else
	-- 			self.treeTab.activeSpec = isValueInArray(self.list, self.treeTab.build.spec)
	-- 		end
	-- 		self.treeTab.modFlag = true
	-- 		self:UpdateItemsTabPassiveTreeDropdown()
	-- 		self.treeTab.build:SyncLoadouts()
	-- 	end)
	-- end
end

function PassiveSpecListClass:OnSelKeyDown(index, spec, key)
	if key == "F2" then
		self:RenameSpec(spec, "Rename Tree")
	end
end

-- Update the passive tree dropdown control in itemsTab
function PassiveSpecListClass:UpdateItemsTabPassiveTreeDropdown()
	local secondarySpecList = self.treeTab.build.itemsTab.controls.specSelect
	local newSpecList = { }
	for i = 1, #self.list do
		newSpecList[i] = self.list[i].title or "Default"
	end
	secondarySpecList:SetList(newSpecList)
	secondarySpecList.selIndex = self.treeTab.activeSpec
end
