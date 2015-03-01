-- TODO: Create a UI implementation which displays feats according to their specifications.

-- Import our modenv.
local modenv = require "feats.modenv"

-- Debugging config stuff.
local debugging = modenv.GetModConfigData("debugprint") or false
print("Debugging is " .. tostring(debugging))

-- PersistentData module stuff.
local PersistentData = require "persistentdata"
local Feats = PersistentData("FeatsData")
local Score = PersistentData("FeatsScore")

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

    -------------------------------------------------------------------

    -- Columns.

    -- Dead center.
	local mid_col = RESOLUTION_X*0

	-- A little to the left.
	local left_col = -RESOLUTION_X*.37

	-- A little to the right.
	local right_col = RESOLUTION_X*.37

	-------------------------------------------------------------------

	-- Set the main anchor.    
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -------------------------------------------------------------------

   	-- Dim the rest of the screen.
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	

    -- Set the panel bg.
    self.feats_panel = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))
    self.feats_panel:SetPosition(mid_col,0,0)

    -- Our title line.
    self.featstitle = self.feats_panel:AddChild(Text(TITLEFONT, 55))
    self.featstitle:SetHAlign(ANCHOR_MIDDLE)
    self.featstitle:SetPosition(mid_col, RESOLUTION_Y*0.3, 0)
    self.featstitle:SetRegionSize(400, 70)
    self.featstitle:SetString("FEATS")

    -- Our score line.
    Score:Load()
    self.featscore = self.feats_panel:AddChild(Text(TITLEFONT, 40))
    self.featscore:SetHAlign(ANCHOR_MIDDLE)
    self.featscore:SetPosition(mid_col, RESOLUTION_Y*0.23, 0)
    self.featscore:SetRegionSize(400, 70)
    self.featscore:SetString("Total Score " .. modenv:GetFeatScore())   

	-------------------------------------------------------------------

    -- Our 'return to main menu' button.
    self.returnbutton = self.root:AddChild(ImageButton())
    self.returnbutton:SetPosition(right_col-80, -100, 0)
    self.returnbutton:SetText("OK")
    self.returnbutton.text:SetColour(0,0,0,1)
    self.returnbutton:SetOnClick(function() self:Return() end)
    self.returnbutton:SetFont(BUTTONFONT)
    self.returnbutton:SetTextSize(40)

	-------------------------------------------------------------------

    -- Make our buttons visible.
	self.default_focus = self.returnbutton
    self.returnbutton:MoveToFront()

    if debugging then
    	print("------------------------------")
		print("DEBUG-FEATS")
	end
	local feats = modenv:GetFeats()
    for keyname,properties in pairs(feats) do
    	self:MakeFeatTile(keyname)
    end

end)

function FeatsScreen:Return()
	TheFrontEnd:PopScreen()
end

-- Our feats grid.
function FeatsScreen:MakeFeatTile(keyname)

	-- Button root.
	--local feattile = feats_panel:AddChild(Widget("button"))

	-- Load our feats data.
  	local feats = modenv:GetFeats()
  	local keyname = feats[keyname]

	local name = keyname[1]
	local description = keyname[2]
	local locked = keyname[3]
	local hidden = keyname[4]
	local score = keyname[5]

	if debugging then
		print("------------------------------")
		print(name)
		print(description)
		print(locked)
		print(hidden)
		print(score)
	end

	--[[
	feattile.bg = widget.base:AddChild(UIAnim())
	feattile.bg:GetAnimState():SetBuild("savetile")
	feattile.bg:GetAnimState():SetBank("savetile")
	feattile.bg:GetAnimState():PlayAnimation("anim")

	feattile.portraitbg = widget.base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))

	return feattile
	--]]
end

function FeatsScreen:OnClickFeat(keyname)
	-- Display the details of the specific feat.
end

return FeatsScreen
