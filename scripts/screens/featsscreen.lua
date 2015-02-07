-- TODO: Create a UI implementation which displays feats according to their specifications.

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

-- We want to load the existing feats.
local cached_feats = loaded_feats

-- Create the feats screen.
local FeatsScreen = Class(Screen, function(self, profile)
    Widget._ctor(self, "FeatsScreen")
    TheFrontEnd:PopScreen(self)
end)

return FeatsScreen