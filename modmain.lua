-- Adds the button for feats.
local function append_feats(self)

    -- Ease of use.
    local Image = require "widgets/image"
    local ImageButton = require "widgets/imagebutton"
    local Text = require "widgets/text"	
    local UIAnim = require "widgets/uianim"

    -- Wrap it up.
    self:MainMenu()
    self.menu:SetFocus()
end

TheMod:AddClassPostConstruct("screens/mainscreen", append_feats)