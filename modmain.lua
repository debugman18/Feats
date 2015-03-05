-- Convenience.
local require = GLOBAL.require

-- Export our modenv.
GLOBAL.package.loaded["feats.modenv"] = env

-- Debugging config stuff.
debugging = GetModConfigData("debugprint")

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

local tiny_score = 5
local small_score = 10
local med_score = 20
local large_score = 50
local huge_score = 100

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

-- Returns the maximum possible score.
GetMaxScore = function ()

    local maxscore = 0

    for keyname,properties in pairs(GetFeats()) do
        local feat_score = properties[5]
        maxscore = maxscore + feat_score
    end

    return maxscore

end

----------------------------------------------------------------------------

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

-- Refresh the description, name, score, and hint of a feat.
-- 1, 2, 5, 6
RefreshFeat = function(keyname, name, description, score, hint)

    Feats:Load()

    local feat_cached = Feats:GetValue(keyname)

    if debugging then
        print("---------------------------")
        print("DEBUG-REFRESH")
        print(keyname)
    end

    for propertykey,value in ipairs(Feats:GetValue(keyname)) do

        if propertykey == 1 then
            feat_cached[1] = name
            if debugging then
                print(name)
                print(Feats:GetValue(keyname)[1])
            end
        end

        if propertykey == 2 then
            feat_cached[2] = description
            if debugging then
                print(description)
                print(Feats:GetValue(keyname)[2])
            end
        end

        if propertykey == 5 then
            feat_cached[5] = score
            if debugging then
                print(score)
                print(Feats:GetValue(keyname)[5])
            end
        end

        if propertykey == 6 then
            feat_cached[6] = hint
            if debugging then
                print(hint)
                print(Feats:GetValue(keyname)[6])
            end
        end
    end

    Feats:SetValue(keyname, feat_cached)
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
                if GLOBAL.GetWorld() then
                    GLOBAL.GetWorld():PushEvent("feat_unlocked")
                end

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
AddFeat = function(keyname, name, description, locked, hidden, score, hint)
    GLOBAL.assert(keyname, "Added feats must have a unique identifier.")
    local name = name or "No Name"
    local description = description or "No Description"
    local locked = locked or false
    local hidden = hidden or false
    local score = score or 0
    local hint = hint or "Fulfill this feat's qualifier to unlock it."

    local feat = {name, description, locked, hidden, score, hint}
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
            print("Hint: " .. hint)
        end
        Feats:SetValue(keyname, feat)
        Save()
        -- Let's assure that we saved.
        print(Feats:GetValue(keyname))
    else
        if debugging then
            print("------------------------------")
            print("Feat " .. "\"" .. name .. "\"" .. " already exists. Refreshing...")
        end
        RefreshFeat(keyname, name, description, score, hint)
        Save()
    end
end

----------------------------------------------------------------------------

-- Unlock all feats.
UnlockAllFeats = function()
    for k,v in pairs(GetFeats()) do
        UnlockFeat(k)
    end
    TheFrontEnd:ShowTitle("You unlocked all Feats",subtitle)
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
AddFeat("DeerGuts", "Deer Guts", "Killed the Deerclops with your bare hands!", true, true, huge_score)

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

-- Killed one rabbit, or 100 rabbits.
AddFeat("RabbitKiller", "Hare Hunter", "Killed your first rabbit.", true, false, tiny_score, "Kill a rabbit to unlock this feat.")
AddFeat("RabbitKiller100", "Rabbit Eradicator", "Killed one-hundred rabbits!", true, true, med_score)

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

-- Reached max science level.
local max_science_hint = "Obtain some uncommon knowledge to unlock this feat."
AddFeat("MaxSciencePrototyper", "Uncommon Knowledge", "Prototyped an item at the Alchemy Engine.", true, false, small_score, max_science_hint)

local function MaxScienceProtyperFlag(inst)
    local onactivate_cached = inst.components.prototyper.onactivate
    inst.components.prototyper.onactivate = function()
        GLOBAL.GetPlayer().components.feattrigger:Trigger("MaxSciencePrototyper")
        GLOBAL.GetPlayer().components.feattrigger:Trigger("MaxMagicPrototyper", true)
        onactivate_cached()
    end
end

AddPrefabPostInit("researchlab2", MaxScienceProtyperFlag)

------------------------------------------------------------

-- Reached max magic level.
local max_magic_hint = "Obtain some dark knowledge to unlock this feat."
AddFeat("MaxMagicPrototyper", "Dark Knowledge", "Prototyped an item at the Shadow Manipulator.", true, true, med_score, max_magic_hint)

local function MaxMagicProtyperFlag(inst)
    local onactivate_cached = inst.components.prototyper.onactivate
    inst.components.prototyper.onactivate = function()
        GLOBAL.GetPlayer().components.feattrigger:Trigger("MaxMagicPrototyper")
        onactivate_cached()
    end
end

AddPrefabPostInit("researchlab3", MaxMagicProtyperFlag)

------------------------------------------------------------

-- Reached ancient level.
AddFeat("AltarPrototyper", "Forgotten Knowledge", "Prototyped an item at the Altar.", true, true, large_score)

local function AltarProtyperFlag(inst)
    local onactivate_cached = inst.components.prototyper.onactivate
    inst.components.prototyper.onactivate = function()
        GLOBAL.GetPlayer().components.feattrigger:Trigger("AltarPrototyper")
        onactivate_cached()
    end
end

AddPrefabPostInit("ancient_altar", AltarProtyperFlag)
AddPrefabPostInit("ancient_altar_broken", AltarProtyperFlag)

------------------------------------------------------------

-- Hatching a tallbird.
local egg_hint = "Hatch an egg to unlock this feat."
AddFeat("TallBirdHatcher", "Almost Food", "Hatched an egg into a Smallbird.", true, false, small_score, egg_hint)

local function TallBirdEggFlag(inst)
    local onstate_cached = inst.components.hatchable.onstatefn
    inst.components.hatchable:SetOnState(function(inst, state)
        print(state)
        if state == "hatch" then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("TallBirdHatcher")
        end
        onstate_cached(inst, state)
    end)
end

AddPrefabPostInit("tallbirdegg_cracked", TallBirdEggFlag)

------------------------------------------------------------

-- Shaving a beefalo.

------------------------------------------------------------

-- Dying from pengulls.
AddFeat("PenguinVictim", "Pengull Chow", "Got killed by a pengull.", true, true, small_score)

local function PengullKillerCheck(inst, deadthing, cause)
    if inst == deadthing then
        if cause == "penguin" then
            inst.components.feattrigger:Trigger("PenguinVictim")
        end
    end
end

AddPrefabPostInitAny(function(inst)
    if inst and inst:HasTag("player") then
        GLOBAL.GetWorld():ListenForEvent("entity_death", function(world, data) PengullKillerCheck(inst, data.inst, data.cause) end)
    end
end)

------------------------------------------------------------

-- Dying from hatched teenbird.
AddFeat("TeenbirdVictim", "Et tu, Brute?", "Got killed by your old friend.", true, true, med_score)

local function TeenbirdKillerCheck(inst, deadthing, cause)
    if inst == deadthing then
        if cause == "teenbird" then
            inst.components.feattrigger:Trigger("TeenbirdVictim")
        end
    end
end

AddPrefabPostInitAny(function(inst)
    if inst and inst:HasTag("player") then
        GLOBAL.GetWorld():ListenForEvent("entity_death", function(world, data) TeenbirdKillerCheck(inst, data.inst, data.cause) end)
    end
end)

------------------------------------------------------------

-- Summon a Krampus.
AddFeat("KrampusVictim", "Naughty, Not Nice", "You were naughty enough to summon Krampus.", true, true, med_score)

local function KrampusFlag(component)
    local naughty_action = component.OnNaughtyAction
    component.OnNaughtyAction = function(self, how_naughty)
        if self.threshold == nil then
            self.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
        end
        local actions = self.actions + (how_naughty or 1)
        if actions >= self.threshold and self.threshold > 0 then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("KrampusVictim")
        end
        naughty_action(self, how_naughty)
    end
end

AddComponentPostInit("kramped", KrampusFlag)

------------------------------------------------------------

-- Kill an Ancient Guardian with an umbrella.
AddFeat("ShadyMinotaur", "Shady Guardian", "Killed the Ancient Guardian with... an umbrella.", true, true, huge_score)

local function ShadyMinotaurCheck(inst, deadthing, cause)
    if debugging then
        print("------------------------------")
        print("SHADYMINOTAURCHECK")
        print(tostring(inst))
        print(tostring(deadthing))
        if cause then
            print("Killer: " .. cause)
        end
        print("Player: " .. GLOBAL.GetPlayer().prefab)
    end
    if GLOBAL.GetPlayer().prefab == cause then
        if GLOBAL.GetPlayer().components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and GLOBAL.GetPlayer().components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS.prefab) == "umbrella" or "grass_umbrella" then
            GLOBAL.GetPlayer().components.feattrigger:Trigger("ShadyMinotaur")
        end
    end 
end

local function ShadyMinotaurFeat(inst)
    inst:ListenForEvent("death", function(inst, data) ShadyMinotaurCheck(inst, data.inst, data.cause) end)
end

AddPrefabPostInit("minotaur", ShadyMinotaurFeat)

------------------------------------------------------------

-- A freebie.
local welcome_description = "Thanks for downloading Feats!\n"
AddFeat("Welcome", "Welcome!", welcome_description, false, false)

------------------------------------------------------------

-- The Accomploshrine should show feats in-game.
local meta_description = "You built an Accomploshrine! Check out your feats in-game!"
AddFeat("MetaFeat", "Feat-Ception", meta_description, true, false, tiny_score, "Build an accomplishment shrine to unlock this feat.")

local function AppendAccomploshrine(inst)

    local percent = GetTotalScore() / GetMaxScore()

    if debugging then
        print("DEBUG-PERCENT")
        print(percent)
    end

    inst.AnimState:SetPercent("active", percent)

    inst:ListenForEvent("onbuilt", function()
        GLOBAL.GetPlayer().components.feattrigger:Trigger("MetaFeat")
    end)

    inst.components.activatable.getverb = function() return "CHECK" end
    inst.components.activatable.OnActivate = function(inst)
        FeatsOpen()
        inst.components.activatable.inactive = true
    end

    GLOBAL.GetWorld():ListenForEvent("feat_unlocked", function()
        percent = GetTotalScore() / GetMaxScore()
        if debugging then
            print("DEBUG-PERCENT")
            print(percent)
        end
        inst.AnimState:SetPercent("active", percent)
    end)

end

AddPrefabPostInit("accomplishment_shrine", AppendAccomploshrine)

GLOBAL.Recipe("accomplishment_shrine", 

    {
        GLOBAL.Ingredient("goldnugget", 10), 
        GLOBAL.Ingredient("cutstone", 1), 
        GLOBAL.Ingredient("gears", 6)
    }, 

    GLOBAL.RECIPETABS.SCIENCE, 
    GLOBAL.TECH.SCIENCE_TWO, 

"accomplishment_shrine_placer")

------------------------------------------------------------

-- Kill 13 followers.
-- A Ritual

------------------------------------------------------------

-- 

------------------------------------------------------------

PropegateDummyFeats = function()

    -- Clear the dummy feats on each load.
    for index,keyname in pairs(GetFeatNames()) do    
        if debugging then
            print("DEBUG-COMPARE")
            print(keyname)
        end

        if string.match(keyname, "Dummy") == "Dummy" then
            Feats:ClearValue(keyname)
            Feats:Save()
        end
    end

    -----------------------------------------

    local feat_count = #GetFeatNames()

    local max_feat_count = 25

    local rounding_factor = 5

    local ideal_feat_count = math.ceil(
        ( (feat_count * (rounding_factor) ) * 0.5 )
    )

    if ideal_feat_count >= max_feat_count then
        ideal_feat_count = max_feat_count
    end

    local dummy_count = ideal_feat_count - feat_count
    local start_array = 1

    local dummy_warning = "This feat is not ready yet!"

    if debugging then
        print("--------------")
        print("DEBUG-DUMMY")
        print("Feat Count: " .. feat_count)
        print("Max Feat Count: " .. max_feat_count)
        print("Ideal Feat Count: " .. ideal_feat_count)
        print("Dummy Count: " .. dummy_count)
        print("--------------")
        print("DEBUG-CLEANING")
    end

    for dummy_id = start_array,dummy_count do
        AddFeat("Dummy" .. dummy_id, "Missing Feat", dummy_warning, true, true, nil, dummy_warning)
    end

end

PropegateDummyFeats()

------------------------------------------------------------