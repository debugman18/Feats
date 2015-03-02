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

-- Number of feats per page.
local display_rows = 5

-- Create the feats screen.
local FeatsScreen = Class(Screen, function(self, profile)
    Widget._ctor(self, "FeatsScreen")

    -- Load and sort our feats.
    if debugging then
    	print("DEBUG-PROPEGATE-FEATS")
    end

    self.featnames = modenv:GetFeatNames()
    self.feats = modenv:GetFeats()

    -- Stuff for scrolling.
    self.featwidgets = {}
    self.option_offset = 0

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
    self.featscore:SetString("Total Score " .. modenv:GetTotalScore()) 

    -- Our feats menu/list.
    self.feats_list = self.feats_panel:AddChild(Menu({}, 60, false))
    self.feats_list:SetPosition(0, -200, 0)

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

    ------------------------------

    -- Scrolling buttons.

	self.leftbutton = self.feats_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.leftbutton:SetPosition(0, 110, 0)
	self.leftbutton:SetRotation(-90)
    self.leftbutton:SetOnClick( function() self:Scroll(-display_rows) end)
	
	self.rightbutton = self.feats_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(0, -265, 0)
	self.rightbutton:SetRotation(90)
    self.rightbutton:SetOnClick( function() self:Scroll(display_rows) end)	

	self:Scroll(0)

end)

function FeatsScreen:Return()
	TheFrontEnd:PopScreen()
end

-- Our feats grid.
function FeatsScreen:MakeFeatTile(keyname)

	-- Load our feats data.
  	local keyname = keyname or self.feats[keyname]

	local name = keyname[1]
	local description = keyname[2]
	local locked = keyname[3]
	local hidden = keyname[4]
	local score = keyname[5]

	if debugging then
		print("------------------------------")
        print("DEBUG-FEAT-TILE")
		print(name)
		print(description)
		print(locked)
		print(hidden)
		print(score)
	end

    ------------------------------

    -- Feat button.
    local feattile = Widget("AnimButton")

    feattile.base = feattile:AddChild(ImageButton())

    -- Apply darkness to locked and/or hidden feats.
    if hidden and locked then
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(3,1.2,1)
        feattile.black:SetPosition(0,5,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
        feattile:Disable()
    elseif locked then
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(3,1.2,1)
        feattile.black:SetPosition(0,5,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
    end

    -- If it isn't hidden, allow us to see the details.
    if not hidden then
        feattile.base:SetOnClick(function()
            if locked then
                TheFrontEnd:PushScreen(BigPopupDialogScreen(name, 
                "This feat is currently locked!\n" .. description .. "\nScore Value: " .. score, 
                {
                    {
                    text = "OK", cb = function() TheFrontEnd:PopScreen() end
                    }  
                }))
            else
                TheFrontEnd:PushScreen(BigPopupDialogScreen(name, 
                description .. "\nScore Value: " .. score, 
                {
                    {
                    text = "OK", cb = function() TheFrontEnd:PopScreen() end
                    }  
                }))
            end
        end)
    end

    feattile.feat_name = feattile:AddChild(Text(BUTTONFONT, 30))
    if not hidden then
        feattile.feat_name:SetString(name)
    else
        feattile.feat_name:SetString("????")
    end
    feattile.feat_name:SetColour(0,0,0,1)

    ------------------------------

    return feattile
end

function FeatsScreen:RefreshOptions()
	if debugging then
		print("DEBUG-REFRESH")
	end

	for k,v in pairs(self.featwidgets) do
		v:Kill()
	end
	self.featwidgets = {}

	self.feats_list:Clear()

	local page_total = math.min(#self.featnames - self.option_offset, display_rows)
	for k = 1, page_total do
	
		local idx = self.option_offset+k

		local featkey = self.featnames[idx]

		-- Load our feats data.
	  	local keyname = self.feats[featkey]

		local tile = self:MakeFeatTile(keyname)

		self.feats_list:AddCustomItem(tile)

		table.insert(self.featwidgets, tile)

	end
end

function FeatsScreen:OnFirstPage()
	return self.option_offset == 0
end

function FeatsScreen:OnLastPage()
	return self.option_offset + display_rows >= #self.featnames
end

function FeatsScreen:Scroll(dir)
	if (dir > 0 and (self.option_offset + display_rows) < #self.featnames) or
		(dir < 0 and self.option_offset + dir >= 0) then
	
		self.option_offset = self.option_offset + dir
	end
	
	self:RefreshOptions()

	if self.option_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.option_offset + display_rows < #self.featnames then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end
end

return FeatsScreen
