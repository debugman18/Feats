-- Convenience.
--GLOBAL.setmetatable(env, {__index=GLOBAL})
local require = GLOBAL.require

-- Export our modenv.
GLOBAL.package.loaded["feats.modenv"] = env

-- Debugging config stuff. --TODO
local debugging = GetModConfigData("debugprint") or false
print("Debugging is " .. tostring(debugging))

-- Screen stuff.
require "prefabutil"
local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local FeatsScreen = require "screens/featsscreen"

-- PersistentData module stuff.
local PersistentData = require "persistentdata"
local Data = PersistentData("FeatsData")

----------------------------------------------------------------------------
 
local function Save(dirty)
    Data:Save(dirty)
    if debugging then
        print("------------------------------")
        print("DEBUG-SAVE")
    end
end
 
local function Load()
    Data:Load()
    if debugging then
        print("------------------------------")
        print("DEBUG-LOAD")
    end
end

----------------------------------------------------------------------------

-- Append the load game menu with feats button.

-- Opens the feats screen.
local function FeatsOpen()
    TheFrontEnd:PushScreen(FeatsScreen())
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

-- Unhide an arbitary feat.
UnhideFeat = function(keyname, callback)
    Load()
    for propertykey,hidden in ipairs(Data:GetValue(keyname)) do
        if propertykey == 4 then
            if debugging then
                print("------------------------------")
                print("DEBUG-UNHIDE")
                print("Feat is hidden:")
                print(hidden)
            end

            hidden = false
            Data:GetValue(keyname)[4] = hidden

            if debugging then
                print("------------------------------")
                print("Unhid: " .. keyname)
                print("------------------------------")

                -- Let's assure the feat is unhidden.
                print("Feat is hidden:")
                print(hidden)     
            end      
        end
    end
    if callback then
        callback()
    end
    Save(true)
end

-- Hide an arbitary feat.
HideFeat = function(keyname, callback)
    Load()
    for propertykey,hidden in ipairs(Data:GetValue(keyname)) do
        if propertykey == 4 then
            if debugging then
                print("------------------------------")
                print("DEBUG-HIDE")
                print("Feat is hidden:")
                print(hidden)
            end

            hidden = true
            Data:GetValue(keyname)[4] = hidden

            if debugging then
                print("------------------------------")
                print("Unhid: " .. keyname)
                print("------------------------------")

                -- Let's assure the feat is hidden.
                print("Feat is hidden:")
                print(hidden)  
            end          
        end
    end
    if callback then
        callback()
    end
    Save(true)
end

----------------------------------------------------------------------------

-- Unlock an arbitary feat.
UnlockFeat = function(keyname, callback)
    Load()
    UnhideFeat(keyname, callback)
    for propertykey,locked in ipairs(Data:GetValue(keyname)) do
        if propertykey == 3 then
            if debugging then
                print("------------------------------")
                print("DEBUG-UNLOCK")
                print("Feat is locked:")
                print(locked)
            end

            locked = false
            Data:GetValue(keyname)[3] = locked

            if debugging then
                print("------------------------------")
                print("Unlocked: " .. keyname)
                print("------------------------------")

                -- Let's assure the feat is unlocked.
                print("Feat is locked:")
                print(locked)
            end            
        end
    end
    Save(true)
end

-- Lock an arbitrary feat.
LockFeat = function(keyname, callback)
    Load()
    for propertykey,locked in ipairs(Data:GetValue(keyname)) do
        if propertykey == 3 then
            if debugging then
                print("------------------------------")
                print("DEBUG-LOCK")
                print("Feat is locked:")
                print(locked)
            end

            locked = true
            Data:GetValue(keyname)[3] = locked

            if debugging then
                print("------------------------------")
                print("Unlocked: " .. keyname)
                print("------------------------------")

                -- Let's assure the feat is locked.
                print("Feat is locked:")
                print(locked)            
            end
        end
    end
    Save(true)
end

----------------------------------------------------------------------------

-- Add a feat to the achievement list.
AddFeat = function(keyname, name, description, locked, hidden)
    GLOBAL.assert(keyname, "Added feats must have a unique identifier.")
    local name = name or "No Name"
    local description = description or "No Description"
    local locked = locked or true
    local hidden = hidden or false

    if debugging then
        print("------------------------------")
        print("Adding feat:")
        print("Key: " .. keyname)
        print("Name: " .. name)
        print("Description: " .. description)
        print("Locked: " .. tostring(locked))
        print("Hidden: " .. tostring(hidden))
    end

    local feat = {name, description, locked, hidden}
    local feat_exists = Data:GetValue(keyname)
    if not feat_exists then
        Data:SetValue(keyname, feat)
        Save()
    elseif debugging then
        print("Feat already exists. Skipping...")
    end

    -- Let's assure that we saved.
    print(Data:GetValue(keyname))
end

------------------------------------------------------------

-- Load before we add feats, so we can do a redundancy check.
Load()

------------------------------------------------------------

-- Add the FeatTrigger component to the player.
AddPrefabPostInitAny(function(inst)
    if inst and inst:HasTag("player") then
        if not inst.components.feattrigger then
            if debugging then
                print("Adding feattrigger component to player.")
            end
            inst:AddComponent("feattrigger")
        end
    end
end)

------------------------------------------------------------

-- Deerclops death by fist.
AddFeat("DeerGuts", "Deer Guts", "Did that honestly behoove you?", true, true)

local function DeerGutsCheck(inst, deadthing, cause)
    if debugging then
        print("DEERGUTSCHECK")
        print(inst.prefab)
        print(deadthing.prefab)
        print(cause)
    end
    if inst.prefab == deadthing.prefab then
        if not GLOBAL.GetPlayer().components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("DeerGuts")
        end
    end 
end

local function DeerGutsFeat(inst)
    GLOBAL.GetWorld():ListenForEvent("entity_death", function(world, data) DeerGutsCheck(inst, data.inst, data.cause) end)
end

AddPrefabPostInit("deerclops", DeerGutsFeat)

------------------------------------------------------------