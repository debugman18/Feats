-- Convenience.
--GLOBAL.setmetatable(env, {__index=GLOBAL})
local require = GLOBAL.require

-- Screen stuff.
require "prefabutil"
local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local FeatsScreen = require "screens/featsscreen"

-- PersistentData module stuff.
local PersistentData = require "persistentdata"
local Data = PersistentData("FeatsData")

----------------------------------------------------------------------------
 
local function Save()
    Data:Save()
    print("------------------------------")
    print("DEBUG-SAVE")
end
 
local function Load()
    Data:Load()
    print("------------------------------")
    print("DEBUG-LOAD")
    print(Data:GetValue("NormalFeat"))
end

----------------------------------------------------------------------------

-- Append the load game menu with feats button.

-- Opens the feats screen.
local function FeatsOpen()
    -- Let's not do this until the screen is done.
    -- TheFrontEnd:PushScreen(FeatsScreen())
end

-- Adds the button for feats.
local function append_feats(self)
    local feats_meta = {{ text = "Feats", cb = function() FeatsOpen() end }}
    self.featsbutton = self.bmenu:AddChild(Menu(feats_meta, 70))
    self.featsbutton:SetPosition(320, 2, 0)
    self.featsbutton:SetScale(1)

    -- Lets make it fit.
    self.bmenu:SetPosition(-120, -250, 0)
end

-- Apply the patch.
AddGlobalClassPostConstruct("screens/loadgamescreen", "LoadGameScreen", append_feats)

----------------------------------------------------------------------------

-- Add a feat to the achievement list.
function AddFeat(keyname, name, description, locked, hidden)
    GLOBAL.assert(keyname, "Added feats must have a unique identifier.")
    local name = name or "No Name"
    local description = description or "No Description"
    local locked = locked or true
    local hidden = hidden or false

    print("------------------------------")
    print("Adding feat:")
    print("Key: " .. keyname)
    print("Name: " .. name)
    print("Description: " .. description)
    print("Locked: " .. tostring(locked))
    print("Hidden: " .. tostring(hidden))

    local feat = {name, description, locked, hidden}
    local feat_exists = Data:GetValue(keyname)
    if not feat_exists then
        Data:SetValue(keyname, feat)
        Save()
    else
        print("Feat already exists. Skipping...")
    end

    -- Let's assure that we saved.
    print(Data:GetValue(keyname))
end

------------------------------------------------------------

-- Unlock an arbitary feat.
function UnlockFeat(keyname)
    for propertykey,locked in pairs(Data:GetValue(keyname)) do
        print("------------------------------")
        print("DEBUG-UNLOCK")
        if propertykey == 3 then
            print("Feat is locked:")
            print(locked)
            locked = false
            print("------------------------------")
            print("Unlocked: " .. keyname)

            -- Let's assure the feat is unlocked.
            print("Feat is locked:")
            print(locked)            
        end
    end
end

------------------------------------------------------------

-- Load before we add feats, so we can do a redundancy check.
Load()

------------------------------------------------------------

-- These are sample feats for testing.
AddFeat("NormalFeat", "Normal Feat", "Normal Feat Description")
AddFeat("LockedFeat", "Locked Feat", "Locked Feat Description", true)
AddFeat("HiddenFeat", "Hidden Feat", "Hidden Feat Description", nil, true)

AddFeat("RainFeat", "Rain Get", "Saw rain!", true)

------------------------------------------------------------

-- Unlock a sample feat.
UnlockFeat("LockedFeat")

------------------------------------------------------------

-- Add our feats to certain events in the world.


