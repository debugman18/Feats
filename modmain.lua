-- For convenience purposes.
local require = GLOBAL.require

require "prefabutil"

local Screen = require "widgets/screen"
local Menu = require "widgets/menu"

local FeatsScreen = require "screens/featsscreen"

-- This won't be nil for long.
loaded_feats = nil

-- Let other mods add their own feats.
feats_collection = {}

----------------------------------------------------------------------------

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

-- Patch our feats into profile data.
local function patch_feats(self)

    -- We don't want to abandon the old set function.
    self.old_Set = self.Set

    -- Avoid redundancy and errors.
    function CreateFeats()
        print("Checking for persistdata.")

        -- TODO: Loaded feats doesn't exist yet.
        print("STEP-2: " .. tostring(loaded_feats))

        if self.persistdata then
            if not loaded_feats then
                print("Feats will now persist.")
                self.persistdata.feats = {debug = {"dummy_name", "dummy_description"}}
                self.dirty = true
                self:Save()
            else
                print("Feats already persist.")
                self.persistdata.feats = loaded_feats or {}
                for k,v in pairs(self.persistdata.feats) do
                    print("DEBUGTABLE")
                    print(tostring(k))
                    for x,y in pairs(v) do
                        print(tostring(x))
                        print(tostring(y))
                    end
                end
            end
        end 
    end

    -- Add a feat to the achievement list.
    function AddFeat(name, description, locked, hidden)
        print("Attempting to add feat(s).")

        -- Add values straight to this temp table.
        local temp_key = {
            name = name,
            description = description,
            locked = locked or nil,
            hidden = hidden or nil
        }

        if self.persistdata and self.persistdata.feats then

            -- TODO: Fix redundancy check.
            table.insert(self.persistdata.feats, temp_key)
            self.dirty = true
            self:Save()

            --[[
            for key,feat in pairs(self.persistdata.feats) do
                for n,string in pairs(feat) do
                    print("DATA_NAME: " .. n)
                    print("FEAT_NAME: " .. name)
                    if not string == name then
                        -- Add our table to the feats table.
                        print("Added " .. name .. " to feats list.")
                        table.insert(self.persistdata.feats, temp_key)
                        self.dirty = true
                        self:Save() 
                    else
                        --The key already exists.
                        print("The key (" .. name .. ") already exists.")
                        self.dirty = true
                        self:Save() 
                    end
                end              
            end
            --]]
        end

    end

    -- Load our dirty variable.
    self.Set = function(self, str, callback)
        print("DEBUGSTRING: " .. str)

        -- Store our dirty variable elsewhere.
        data = GLOBAL.json.decode(str)
        local feats = data["feats"]
        if feats then
            for k,v in pairs(feats) do
                for n,string in pairs(v) do
                    if n == name then
                        print("DEBUGDATA: " .. string)
                    end
                end
            end
        end
        loaded_feats = data["feats"]
        print("STEP-1: " .. tostring(loaded_feats))

        -- Initialize the feats table.
        CreateFeats()

        -- These are sample feats for testing.
        AddFeat("Debug Feat", "Debug Feat Description")
        AddFeat("Test Feat", "Test Feat Description")
        AddFeat("Dummy Feat", "Dummy Feat Description")

        -- Add feats from other mods.
        print("DEBUGEXTERNAL")
        for functionkey,functionvalue in pairs(feats_collection) do         
            ------------------------------------------------------------
            -- Here we want to run any external instances of AddFeat. --
            ------------------------------------------------------------
            functionvalue()
        end

        self:old_Set(str, callback)
    end 

    --Uncomment to reset save data if needed.
    --self:Reset()
end

-- Apply the patch.
AddGlobalClassPostConstruct("playerprofile", "PlayerProfile", patch_feats)

-- Sample externally added feat.
local ext_feat = function() AddFeat("External Feat", "External Feat Description", locked = true, hidden = false) end
table.insert(feats_collection, ext_feat)

