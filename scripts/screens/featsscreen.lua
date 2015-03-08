-- Import our modenv.
local modenv = require "feats.modenv"

-- Debugging config stuff.
local debugging = modenv.GetModConfigData("debugprint")

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
local neat_mult = 4
local to_beginning = neat_mult * display_rows
local to_end = -to_beginning

-- Create the feats screen.
local FeatsScreen = Class(Screen, function(self, profile)

    if GetWorld() then
        SetPause(true)
    end

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

        if debugging then
            print(feat_a[1])
            print(feat_a[3])
            print(feat_a[4])
            print(feat_a[5])
        end

        local locked_a = feat_a[3]
        local hidden_a = feat_a[4]
        local score_a = feat_a[5]
        local name_a = feat_a[1]

        local feat_b = self.feats[b]

        if debugging then
            print(feat_b[1])
            print(feat_b[3])
            print(feat_b[4])
            print(feat_b[5])
        end

        local locked_b = feat_b[3]
        local hidden_b = feat_b[4]
        local score_b = feat_b[5]
        local name_b = feat_b[1]

        if debugging then
            print("LOCKED_CHECK:")
            print(tostring(locked_a) .. "_" .. tostring(locked_b))
            print("COMPARE CHECK:")
            print(tostring(hidden_a) .. "_" .. tostring(locked_b))
            print("HIDDEN CHECK:")
            print(tostring(hidden_a) .. "_" .. tostring(hidden_b))
            print("SCORE CHECK:")
            print(tostring(score_a) .. "_" .. tostring(score_b))
        end

        -- Put unlocked feats above/before locked feats.
        if tostring(locked_b) < tostring(locked_a) then

            if debugging then
                print("DEBUG-LOCKED-SORT")

                print(locked_a)
                print(locked_b)
            end

            return tostring(locked_b) < tostring(locked_a)
        
        -- Put unhidden feats above/before hidden feats.
        elseif tostring(hidden_b) < tostring(hidden_a) then

            if debugging then
                print("DEBUG-HIDDEN-SORT")

                print(hidden_a)
                print(hidden_b)
            end

            return tostring(hidden_b) < tostring(hidden_a)

        -- Then, sort by score value.
        elseif (not locked_a) and (not locked_b) and score_b < score_a then

            if debugging then
                print("DEBUG-SCORE-SORT")

                print(score_a)
                print(score_b)
            end

            return score_b < score_a          

        end 

    end)

    -------------------------------------------------------------------

    -- Stuff for scrolling.
    self.featwidgets = {}
    self.option_offset = 0

    -- Set our background here.
    -- We don't really need this, I think.
    --[[
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
    --]]

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
    self.feats_list = self.feats_panel:AddChild(Menu({}, 75, false))
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
    self.leftbutton:SetPosition(-180, -20, 0)
	self.leftbutton:SetRotation(-180)
    self.leftbutton:SetOnClick(function() self:Scroll(display_rows) end)
	
	self.rightbutton = self.feats_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(180, -20, 0)
	self.rightbutton:SetRotation(0)

	self:Scroll(to_beginning)

end)

-- ESC/Pause Button will close the feats menu.
function FeatsScreen:OnControl(control, down)
    if FeatsScreen._base.OnControl(self,control, down) then return true end

    if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then 
        self:Return()
        return true
    end
end

function FeatsScreen:Return()
    SetPause(false)
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


    feattile.base = feattile:AddChild(ImageButton("images/ui.xml", "nondefault_customization.tex"))

    -- Checkboxes. Meh.
    --[[
    if not locked then
        feattile.checkbox = feattile:AddChild(Image("images/ui.xml", "button_checkbox2.tex"))
        feattile.checkbox:SetPosition(-110, 5, 0)
        feattile.checkbox:SetScale(0.6,0.6,0.6)        
    else
        feattile.checkbox = feattile:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
        feattile.checkbox:SetPosition(-110, 5, 0)
        feattile.checkbox:SetScale(0.6,0.6,0.6)  
    end
    --]]

    -- Icons. Meh.
    --[[
    if not hidden then
        feattile.featicon = feattile:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
        --feattile.featicon = feattile:AddChild(Image("images/feat_unknown.xml", "images/feat_" .. keyname .. ".tex"))--
        feattile.featicon:SetPosition(-110, 3, 0)
        feattile.featicon:SetScale(0.38,0.38,0.38)        
    else
        feattile.featicon = feattile:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
        --feattile.featicon = feattile:AddChild(Image("images/feat_unknown.xml", "images/feat_unknown.tex"))
        feattile.featicon:SetPosition(-110, 3, 0)
        feattile.featicon:SetScale(0.38,0.38,0.38)  
    end   
    ]] 

    -- Apply darkness to locked and/or hidden feats.
    if hidden and locked then     
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(6,1.5,1)
        feattile.black:SetPosition(0,4.3,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
    elseif locked then
        feattile.black = feattile:AddChild(Image("images/global.xml", "square.tex"))
        feattile.black:SetScale(6,1.5,1)
        feattile.black:SetPosition(0,4.3,0)
        feattile.black:SetTint(0,0,0,.75)
        feattile.black:SetClickable(false)
    end

    -- If it isn't hidden, allow us to see the details.
    feattile.base:SetOnClick(function()
        if hidden and locked then

            TheFrontEnd:PushScreen(BigPopupDialogScreen("????", "Fulfill this feat's qualifier to see it.", 
            {
                {
                text = "OK", cb = function() TheFrontEnd:PopScreen() end
                }  
            }))

        elseif locked then

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
		print("DEBUG-SCREEN-LOAD")
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
        self.leftbutton:SetOnClick(function() self:Scroll(display_rows) end)
    else
        self.leftbutton:SetOnClick(function() self:Scroll(to_end) end)
    end
    
    if self.option_offset > 0 then
        self.rightbutton:SetOnClick(function() self:Scroll(-display_rows) end) 
    else
        self.rightbutton:SetOnClick(function() self:Scroll(to_beginning) end) 
    end    
end

return FeatsScreen
