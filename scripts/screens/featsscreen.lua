-- TODO: Create a UI implementation which displays feats according to their specifications.

-- PersistentData module stuff.
local PersistentData = require "persistentdata"
local Data = PersistentData("FeatsData")

-- For convenience.
local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local HoverText = require "widgets/hoverer"
local NumericSpinner = require "widgets/numericspinner"
local PopupDialogScreen = require "screens/popupdialog"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local MainScreen = require "screens/mainscreen"

-- Create the feats screen.
local FeatsScreen = Class(Screen, function(self, profile)
    Widget._ctor(self, "FeatsScreen")

    -- Set our background here.
    self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    if IsDLCEnabled(REIGN_OF_GIANTS) then
   	    self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
   	else
   		self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
   	end

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    -- Columns.
    local left_col = -RESOLUTION_X*.05 - 60
    local right_col = RESOLUTION_X*.40 - 130

	-- Set the main anchor.    
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- Our 'return to main menu' button.
    self.returnbutton = self.root:AddChild(ImageButton())
    self.returnbutton:SetPosition(right_col, 0, 0)
    self.returnbutton:SetText("OK")
    self.returnbutton.text:SetColour(0,0,0,1)
    self.returnbutton:SetOnClick(function() self:Return() end)
    self.returnbutton:SetFont(BUTTONFONT)
    self.returnbutton:SetTextSize(40)

    -- Controller support.
    --[[
	--self.returnbutton:SetFocusChangeDir(MOVE_LEFT, self.applybutton)
	--self.returnbutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
	--self.returnbutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)
	--]]

    -- Make our buttons visible.
	self.default_focus = self.returnbutton
    self.returnbutton:MoveToFront()
end)

function FeatsScreen:Return()
	TheFrontEnd:PopScreen()
end

return FeatsScreen
