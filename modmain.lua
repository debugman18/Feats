-- Convenience.
--GLOBAL.setmetatable(env, {__index=GLOBAL})
local require = GLOBAL.require

-- Export our modenv.
GLOBAL.package.loaded["feats.modenv"] = env

-- Debugging config stuff.
local debugging = GetModConfigData("debugprint") or false
print("Debugging is " .. tostring(debugging))

-- Screen stuff.
require "prefabutil"
local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local FeatsScreen = require "screens/featsscreen"

-- PersistentData module stuff.
local PersistentData = require "persistentdata"

local Feats = PersistentData("FeatsData")
local Score = PersistentData("FeatsScore")
local Stats = PersistentData("FeatsMetrics")

----------------------------------------------------------------------------
 
local function Save(dirty)
    Feats:Save(dirty)
    Score:Save(dirty)
    Stats:Save(dirty)
    if debugging then
        print("------------------------------")
        print("DEBUG-SAVE")
    end
end
 
local function Load()
    Feats:Load()
    Score:Load()
    Stats:Load()
    if debugging then
        print("------------------------------")
        print("DEBUG-LOAD")
    end
end

----------------------------------------------------------------------------

-- Return the score, if it exists.
GetTotalScore = function()
    Score:Load()
    return Score:GetValue("FeatsScore") or 0
end

-- Return feats, if they exist.
GetFeats = function()
    Feats:Load()
    return Feats.persistdata
end

-- Return feat key names. This is virtually the same as above.
GetFeatNames = function()
    local feats = GetFeats()
    local featnames = {}
    for keyname,properties in pairs(feats) do
        table.insert(featnames, keyname)
    end

    if debugging then
        print("DEBUG-GETFEATNAMES")
        for k,v in pairs(featnames) do
            print(k)
            print(v)
        end
    end

    return featnames
end

-- Return feat name.
GetFeatName = function(featname)
    Feats:Load()

    local feat = Feats:GetValue(featname)
    local name = feat[1] 

    return name
end

-- Return feat description.
GetFeatDescription = function(featname)
    Feats:Load()

    local feat = Feats:GetValue(featname)
    local description = feat[2] 

    return description
end

-- Return feat locked status.
GetFeatLocked = function(featname)
    Feats:Load()

    local feat = Feats:GetValue(featname)
    local locked = feat[3] 

    return locked
end

-- Return feat hidden status.
GetFeatHidden = function(featname)
    Feats:Load()

    local feat = Feats:GetValue(featname)
    local hidden = feat[4] 

    return hidden
end

-- Return feat score value.
GetFeatScore = function(featname)
    Feats:Load()

    local feat = Feats:GetValue(featname)
    local score = feat[5]

    return score 
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
    Feats:Load()
    for propertykey,hidden in ipairs(Feats:GetValue(keyname)) do
        if propertykey == 4 then
            if debugging then
                print("------------------------------")
                print("DEBUG-UNHIDE")
                print("Feat is hidden:")
                print(hidden)
            end

            hidden = false
            Feats:GetValue(keyname)[4] = hidden
            Feats:Save(true)

            if debugging then
                print("------------------------------")
                print("Unhid: " .. keyname)

                -- Let's assure the feat is unhidden.
                print("------------------------------")
                print("Feat is hidden:")
                print(hidden)     
            end      
        end
    end
    if callback then
        callback()
    end
end

-- Hide an arbitary feat.
HideFeat = function(keyname, callback)
    Feats:Load()
    for propertykey,hidden in ipairs(Feats:GetValue(keyname)) do
        if propertykey == 4 then
            if debugging then
                print("------------------------------")
                print("DEBUG-HIDE")
                print("Feat is hidden:")
                print(hidden)
            end

            hidden = true
            Feats:GetValue(keyname)[4] = hidden
            Feats:Save(true)

            if debugging then
                print("------------------------------")
                print("Unhid: " .. keyname)

                -- Let's assure the feat is hidden.
                print("------------------------------")
                print("Feat is hidden:")
                print(hidden)  
            end          
        end
    end
    if callback then
        callback()
    end
end

----------------------------------------------------------------------------

-- Unlock an arbitary feat.
UnlockFeat = function(keyname, callback)
    Load()
    for propertykey,locked in ipairs(Feats:GetValue(keyname)) do
        if propertykey == 3 then
            if debugging then
                print("------------------------------")
                print("DEBUG-UNLOCK")
                print("Feat is locked:")
                print(locked)
            end

            -- Make sure the feat has not been unlocked already.
            if locked == true then

                -- Notify the player.
                local title = "You accomplished a new feat!\n" .. "\"" .. Feats:GetValue(keyname)[1] .. "\""
                TheFrontEnd:ShowTitle(title,subtitle)

                -- Unhide the feat, since it's unlocked now.
                UnhideFeat(keyname, callback)

                -- Increase our total score.
                for scorekey,score in ipairs(Feats:GetValue(keyname)) do
                    if scorekey == 5 then
                        if debugging then
                            print("------------------------------")
                            print("DEBUG-SCORE")
                            print("Feat has score value of:")
                            print(score)
                        end

                        local oldscore = Score:GetValue("FeatsScore") or 0
                        newscore = oldscore + score
                        Score:SetValue("FeatsScore", newscore)
                        Score:Save(true)

                        if debugging then
                            -- Let's assure the score is changed.
                            print("------------------------------")
                            print("Old score was:")
                            print(oldscore)

                            print("------------------------------")
                            print("Total score is now:")
                            print(newscore)
                        end            
                    end
                end
            end

            locked = false
            Feats:GetValue(keyname)[3] = locked
            Feats:Save(true)

            if debugging then
                print("------------------------------")
                print("Unlocked: " .. keyname)
                print("------------------------------")

                -- Let's assure the feat is unlocked.
                print("------------------------------")
                print("Feat is locked:")
                print(locked)
            end            
        end
    end
end

-- Lock an arbitrary feat.
LockFeat = function(keyname, callback)
    Load()
    for propertykey,locked in ipairs(Feats:GetValue(keyname)) do
        if propertykey == 3 then
            if debugging then
                print("------------------------------")
                print("DEBUG-LOCK")
                print("Feat is locked:")
                print(locked)
            end

            locked = true
            Feats:GetValue(keyname)[3] = locked
            Feats:Save(true)

            if debugging then
                print("------------------------------")
                print("Unlocked: " .. keyname)

                -- Let's assure the feat is locked.
                print("------------------------------")
                print("Feat is locked:")
                print(locked)            
            end
        end
    end
end

----------------------------------------------------------------------------

-- Add a feat to the achievement list.
AddFeat = function(keyname, name, description, locked, hidden, score)
    GLOBAL.assert(keyname, "Added feats must have a unique identifier.")
    local name = name or "No Name"
    local description = description or "No Description"
    local locked = locked or true
    local hidden = hidden or false
    local score = score or 0

    local feat = {name, description, locked, hidden, score}
    local feat_exists = Feats:GetValue(keyname)
    if debugging then
        print("------------------------------")
        print("DEBUG-REDUNDANCY")
    end
    if not feat_exists then
        if debugging then
            print("------------------------------")
            print("Adding feat:")
            print("Key: " .. keyname)
            print("Name: " .. name)
            print("Description: " .. description)
            print("Locked: " .. tostring(locked))
            print("Hidden: " .. tostring(hidden))
            print("Score: " .. tostring(score))
        end
        Feats:SetValue(keyname, feat)
        Save()
        -- Let's assure that we saved.
        print(Feats:GetValue(keyname))
    elseif debugging then
        print("------------------------------")
        print("Feat " .. "\"" .. name .. "\"" .. " already exists. Skipping...")
    end
end

------------------------------------------------------------

-- Load before we add feats, so we can do a redundancy check.
Load()

------------------------------------------------------------

-- Sometimes we need to reset everything.
ResetAll = function()
    if debugging then
        print("------------------------------")
        print("DEBUG-RESET")
    end
    Feats:Reset()
    Score:Reset()
    Stats:Reset()
    Save(true)
end

-- Uncomment to reset everything.
--ResetAll()

------------------------------------------------------------

-- Add the FeatTrigger component to the player.
AddPrefabPostInitAny(function(inst)
    if inst and inst:HasTag("player") then
        if not inst.components.feattrigger then
            if debugging then
                print("------------------------------")
                print("Adding feattrigger component to player.")
            end
            inst:AddComponent("feattrigger")
        end
    end
end)

------------------------------------------------------------

-- Deerclops death by fist.
AddFeat("DeerGuts", "Deer Guts", "Killed the Deerclops with your bare hands!", true, true, 100)

local function DeerGutsCheck(inst, deadthing, cause)
    if debugging then
        print("------------------------------")
        print("DEERGUTSCHECK")
        print(tostring(inst))
        print(tostring(deadthing))
        if cause then
            print("Killer: " .. cause)
        end
        print("Player: " .. GLOBAL.GetPlayer().prefab)
    end
    if GLOBAL.GetPlayer().prefab == cause then
        if not GLOBAL.GetPlayer().components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("DeerGuts")
        end
    end 
end

local function DeerGutsFeat(inst)
    inst:ListenForEvent("death", function(inst, data) DeerGutsCheck(inst, data.inst, data.cause) end)
end

AddPrefabPostInit("deerclops", DeerGutsFeat)

------------------------------------------------------------

-- Killed a rabbit or rabbits.
AddFeat("RabbitKiller", "Rabbit Slayer", "Killed an innocent rabbit.", true, false, 5)
AddFeat("RabbitKiller100", "Rabbit Eradicator", "Killed one-hundred rabbits!", true, true, 25)

local function RabbitKillerCheck(inst, deadthing, cause)
    Stats:Load()

    local rabbitkills = Stats:GetValue("RabbitKills") or 0
    local num = rabbitkills + 1

    if debugging then
        print("------------------------------")
        print("RABBITKILLERCHECK")
        print(tostring(inst))
        print(tostring(deadthing))
        if cause then
            print("Killer: " .. cause)
        end
        print("Player: " .. GLOBAL.GetPlayer().prefab)
    end

    -- Make sure a player did the killing.
    if GLOBAL.GetPlayer().prefab == cause then
        Stats:SetValue("RabbitKills", num)
        Stats:Save(true)

        if debugging then
            print("------------------------------")
            print("DEBUG-METRICS")
            print("RABBITKILLS:")
            print(num)
        end

        if rabbitkills <= 1 then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("RabbitKiller")
        elseif rabbitkills >= 100 then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("RabbitKiller100")
        end
    end 

end

local function RabbitKillerFeat(inst)
    inst:ListenForEvent("death", function(inst, data) RabbitKillerCheck(inst, data.inst, data.cause) end)
end

AddPrefabPostInit("rabbit", RabbitKillerFeat)

------------------------------------------------------------

-- Dummy feats to test scrolling.
AddFeat("Dummy0", "Dummy0", "This exists to test scrolling.")
AddFeat("Dummy1", "Dummy1", "This exists to test scrolling.")
AddFeat("Dummy2", "Dummy2", "This exists to test scrolling.")
AddFeat("Dummy3", "Dummy3", "This exists to test scrolling.")
AddFeat("Dummy4", "Dummy4", "This exists to test scrolling.")
AddFeat("Dummy5", "Dummy5", "This exists to test scrolling.")
AddFeat("Dummy6", "Dummy6", "This exists to test scrolling.")