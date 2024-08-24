-- Path of Building
--
-- Class: Radio Button Control
-- Basic radio button control.
--

local pairs = pairs
local t_insert = table.insert


local highlightRing = NewImageHandle()
highlightRing:Load("Assets/small_ring.png", "CLAMP")
local highlightCircle = NewImageHandle()
highlightCircle:Load("Assets/small_circle.png", "CLAMP")

local RadioButtonClass = newClass("RadioButtonControl","CheckBoxControl", function(self, anchor, x, y, size, label, changeFunc, tooltipText, initialState)
	self.CheckBoxControl(anchor, x, y, size, label, changeFunc, tooltipText, initialState)
	-- stores the other members of the radio group
	self.radioGroup = {}
end)

function CreateRadioButtonGroup(...)
    local arg={...}
	for i,v in pairs(arg) do
		for i2,v2 in pairs(arg) do
			if i ~= i2 then
				v:AddToRadioGroup(v2)
			end
		end
        
	end
end

function RadioButtonClass:AddToRadioGroup(radiobutton)
    t_insert(self.radioGroup, radiobutton)
end

function RadioButtonClass:UntickOtherRadiogroupMembers()
	for i,v in ipairs(self.radioGroup) do
        v.state = false
		if v.changeFunc then
			v.changeFunc(v.state)
		end
	end
end

function RadioButtonClass:IsMouseOver()
	if self.state then
		return false
	else
		return self.CheckBoxControl:IsMouseOver()
	end
end

function RadioButtonClass:Draw(viewPort, noTooltip)
	local x, y = self:GetPos()
	local size = self.width
	local enabled = self:IsEnabled()
	local mOver = self:IsMouseOver()
	

	if not enabled then
		SetDrawColor(0, 0, 0)
	elseif self.clicked and mOver then
		SetDrawColor(0.5, 0.5, 0.5)
	elseif mOver then
		SetDrawColor(0.33, 0.33, 0.33)
	else
		SetDrawColor(0, 0, 0)
	end

	DrawImage(highlightCircle, x, y, size, size)

	if not enabled then
		SetDrawColor(0.33, 0.33, 0.33)
	elseif mOver then
		SetDrawColor(1, 1, 1)
	elseif self.borderFunc then
		local r, g, b = self.borderFunc()
		SetDrawColor(r, g, b)
	else
		SetDrawColor(0.5, 0.5, 0.5)
	end
	DrawImage(highlightRing, x, y, size, size)

	if self.state then
		if not enabled then
			SetDrawColor(0.33, 0.33, 0.33)
		elseif mOver then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(0.75, 0.75, 0.75)
		end
		main:DrawCheckMark(x + size/2, y + size/2, size * 0.8)
	end
	if enabled then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.33, 0.33, 0.33)
	end
	local label = self:GetProperty("label")
	if label then
		DrawString(x - 5, y + 2, "RIGHT_X", size - 4, "VAR", label)
	end
	if mOver and not noTooltip then
		SetDrawLayer(nil, 100)
		self:DrawTooltip(x, y, size, size, viewPort, self.state)
		SetDrawLayer(nil, 0)
	end
end


function RadioButtonClass:OnKeyDown(key)
	if not self:IsShown() or not self:IsEnabled() or self.state then
		return
	end
	if key == "LEFTBUTTON" then
		self.clicked = true
	end
	return self
end


function RadioButtonClass:OnKeyUp(key)
	if not self:IsShown() or not self:IsEnabled() or self.state then
		return
	end
	if key == "LEFTBUTTON" then
		if self:IsMouseOver() then
			self.state = not self.state
			self:UntickOtherRadiogroupMembers()
			if self.changeFunc then
				self.changeFunc(self.state)
			end
		end
	end
	self.clicked = false
end
