-- TODO: Create a UI implementation which displays feats according to their specifications.

-- Import our modenv.
local modenv = require "feats.modenv"

-- Debugging config stuff.
local debugging = function() 
    if modenv.GetModConfigData("debugprint") == true then
        print("Debugging is true.")
        return true
    else
        print("Debugging is false.")
        return nil  
    end
end
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

    -------------------------------------------------------------------

    -- We'll sort the feats table.
    if debugging then
        print("------------------------------")
        print("DEBUG-SORT")
    end

    table.sort(self.featnames, function(a,b)

        local feat_a = self.feats[a]

        print(feat_a[1])
        print(feat_a[3])
        print(feat_a[4])

        local locked_a = feat_a[3]
        local hidden_a = feat_a[4]

        local feat_b = self.feats[b]

        print(feat_b[1])
        print(feat_b[3])
        print(feat_b[4])

        local locked_b = feat_b[3]
        local hidden_b = feat_b[4]

        print("LOCKED_CHECK:")
        print(tostring(locked_a) .. "_" .. tostring(locked_b))
        print("COMPARE CHECK:")
        print(tostring(hidden_a) .. "_" .. tostring(locked_b))
        print("HIDDEN CHECK:")
        print(tostring(hidden_a) .. "_" .. tostring(hidden_b))

        -- Put unlocked feats below/before locked feats.
        if tostring(locked_b) < tostring(locked_a) then

            print("DEBUG-LOCKED-SORT")

            print(locked_a)
            print(locked_b)

            return tostring(locked_b) < tostring(locked_a)
        
        -- Put unhidden feats above/after hidden feats.
        elseif tostring(hidden_b) < tostring(hidden_a) then

            print("DEBUG-HIDDEN-SORT")

            print(hidden_a)
            print(hidden_b)

            return tostring(hidden_b) < tostring(hidden_a)

        end 

    end)

    -------------------------------------------------------------------

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

	self.upbutton = self.feats_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.upbutton:SetPosition(0, 110, 0)
	self.upbutton:SetRotation(-90)
    self.upbutton:SetOnClick( function() self:Scroll(display_rows) end)
	
	self.downbutton = self.feats_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.downbutton:SetPosition(0, -265, 0)
	self.downbutton:SetRotation(90)
    self.downbutton:SetOnClick( function() self:Scroll(-display_rows) end)	

	self:Scroll(self.option_offset + display_rows)

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
    local hint = keyname[6]

	if debugging then
		print("------------------------------")
        print("DEBUG-FEAT-TILE")
		print(name)
		print(description)
		print(locked)
		print(hidden)
		print(score)
        print(hint)
	end

    ------------------------------

    -- Feat button.
    local feattile = Widget("AnimButton")

    feattile.base = feattile:AddChild(ImageButton())

    -- Apply darkness to locked and/or hidden feats.
    if hidden and locked then
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(3,1.1,1)
        feattile.black:SetPosition(0,4.7,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
        feattile:Disable()
    elseif locked then
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(3,1.1,1)
        feattile.black:SetPosition(0,4.7,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
    end

    -- If it isn't hidden, allow us to see the details.
    if not hidden then
        feattile.base:SetOnClick(function()
            if locked then
                TheFrontEnd:PushScreen(BigPopupDialogScreen(name, 
                "This feat is currently locked!\n" .. hint .. "\nScore Value: " .. score, 
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
        print("------------------------------")
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

    if self.option_offset + display_rows < #self.featnames then
        self.upbutton:Show()
    else
        self.upbutton:Hide()
    end
    
    if self.option_offset > 0 then
        self.downbutton:Show()
    else
        self.downbutton:Hide()
    end    
end

return FeatsScreen
