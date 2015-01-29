-- For convenience purposes.
local require = GLOBAL.require

require "prefabutil"

local Screen = require "widgets/screen"
local Menu = require "widgets/menu"

local FeatsScreen = require "screens/featsscreen"

-- This won't be nil for long.
local loaded_feats = nil

----------------------------------------------------------------------------

local feats_collection = {
    
}

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

    -- Load our dirty variable.
    self.Set = function(self, str, callback)
        print("DEBUGSTRING" .. str)

        -- Store our dirty variable elsewhere.
        data = GLOBAL.json.decode(str)
        local feats = data["feats"]
        for k,v in pairs(feats) do
            for name,string in pairs(v) do
                if name == name then
                    print("DEBUGDATA: " .. string)
                end
            end
        end
        self.persistdata.feats = data["feats"]

        self:old_Set(str, callback)
    end

    -- Avoid redundancy and errors.
    print("Checking for persistdata.")
    if self.persistdata then
        if not loaded_feats then
            print("Feats will now persist.")
            self.persistdata.feats = {debug = {"debug_name", "debug_description"}}
            self.dirty = true
            self:Save()
        else
            print("Feats already persist.")
        end
    end    

    -- Add a feat to the achievement list.
    function self:AddFeat(name, description, locked, hidden)
        -- Add values straight to this temp table.
        local temp_key = {
            name = name, 
            description = description, 
            locked = locked or nil, 
            hidden = hidden or nil
        }

        if self.persistdata then
            if not self.persistdata.feats[temp_key] then
                -- Add our table to the feats table.
                if self.persistdata.feats then
                    print("Added " .. name .. " to feats list.")
                    table.insert(self.persistdata.feats, temp_key)
                    --self.persistdata.feats[key].name = name
                    --self.persistdata.feats[key].description = description
                    --self.persistdata.feats[key].locked = locked or nil
                    --self.persistdata.feats[key].hidden = hidden or nil                     
                end
            else
                -- The key already exists.
                print("The key (" .. name .. ") already exists.")
            end
        end
    end

    -- Print list of feats.
    for k,v in pairs(self.persistdata) do
        print(k)
        if type(v) == "table" then
            print(v)
            for a,b in pairs(v) do
                print(b)
            end
        end
    end

    -- This is a sample feat for testing.
    self.AddFeat("Sample Feat", "Sample Feat Description")
end

AddGlobalClassPostConstruct("playerprofile", "PlayerProfile", patch_feats)