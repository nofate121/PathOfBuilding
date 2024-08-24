-- Path of Building
--
-- Class: Section Control
-- Section box with label
--

local SectionClass = newClass("SectionControl", "Control", function(self, anchor, x, y, width, height, label)
	self.Control(anchor, x, y, width, height)
	self.label = label
	self.backgroundDrawlayer = -10
	self.backgroundColor = 0.1
end)

function SectionClass:Draw()
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	SetDrawLayer(nil, self.backgroundDrawlayer)
	SetDrawColor(0.66, 0.66, 0.66)
	DrawImage(nil, x, y, width, height)
	SetDrawColor(self.backgroundColor, self.backgroundColor, self.backgroundColor)
	DrawImage(nil, x + 2, y + 2, width - 4, height - 4)
	SetDrawLayer(nil, 0)
	local label = self:GetProperty("label")
	local labelWidth = DrawStringWidth(14, "VAR", label)
	SetDrawColor(0.66, 0.66, 0.66)
	DrawImage(nil, x + 6, y - 8, labelWidth + 6, 18)
	SetDrawColor(0, 0, 0)
	DrawImage(nil, x + 7, y - 7, labelWidth + 4, 16)
	SetDrawColor(1, 1, 1)
	DrawString(x + 9, y - 6, "LEFT", 14, "VAR", label)
end