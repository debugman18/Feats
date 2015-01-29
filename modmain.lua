-- For convenience purposes.
local require = GLOBAL.require

require "prefabutil"

local Screen = require "widgets/screen"
local Menu = require "widgets/menu"

local FeatsScreen = require "screens/featsscreen"

-- This won't be nil for long.
local loaded_feats = nil

----------------------------------------------------------------------------

-- Opens the feats screen.
local function FeatsOpen()
    -- Lets not do this until the screen is done.
    --TheFrontEnd:PushScreen(FeatsScreen())
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
                self.persistdata.feats = {}
                self.dirty = true
                self:Save()
            else
                print("Feats already persist.")
                self.persistdata.feats = loaded_feats
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
            for key,feat in pairs(self.persistdata.feats) do
                for n,string in pairs(feat) do
                    if n == name then
                        -- Add our table to the feats table.
                        print("Added " .. name .. " to feats list.")
                        table.insert(self.persistdata.feats, temp_key)
                        self.dirty = true
                        self:Save() 
                    else
                        -- The key already exists.
                        print("The key (" .. name .. ") already exists.")
                    end
                end
            end
        end
    end

    -- Load our dirty variable.
    self.Set = function(self, str, callback)
        print("DEBUGSTRING: " .. str)

        -- Store our dirty variable elsewhere.
        data = GLOBAL.json.decode(str)
        local feats = data["feats"]
        for k,v in pairs(feats) do
            for n,string in pairs(v) do
                if n == name then
                    print("DEBUGDATA: " .. string)
                end
            end
        end
        loaded_feats = data["feats"]
        print("STEP-1: " .. tostring(loaded_feats))

        -- Initialize the feats table.
        CreateFeats()

        -- This is a sample feat for testing.
        AddFeat("Sample Feat", "Sample Feat Description")

        self:old_Set(str, callback)
    end 

end

AddGlobalClassPostConstruct("playerprofile", "PlayerProfile", patch_feats)