-- For convenience purposes.
local require = GLOBAL.require

require "prefabutil"

local Screen = require "widgets/screen"
local Menu = require "widgets/menu"

local FeatsScreen = require "screens/featsscreen"

local achievements = require "achievements"

----------------------------------------------------------------------------

-- Opens the feats screen.
local function FeatsOpen()
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

    -- Avoid redundancy and errors.
    if self.persistdata then
        if not self.persistdata.feats then
            print("Feats will now persist.")
            self.persistdata.feats = {"debug"}
            self:Save()
        else
            print("Feats already persist.")
        end
    end

    -- Add a feat to the achievement list.
    local function AddFeat(profile, key, name, description, locked, hidden)
        if not self.persistdata.feats[key] then
            print("Added " .. key .. " to feats list.")
            for k,v in pairs(self.persistdata) do
                if k == feats then
                    for a,b in pairs(v) do
                        if b then
                            -- The key already exists.
                            print("The key (" .. key .. ") already exists.")
                        else
                            -- The key needs to be added.
                            table.insert(a, key)
                            --self.persistdata.feats[key].name = name
                            --self.persistdata.feats[key].description = description
                            --self.persistdata.feats[key].locked = locked or nil
                            --self.persistdata.feats[key].hidden = hidden or nil 
                        end
                    end
                end
            end
        end
    end

    -- Print list of feats.
    print("Checking for persistdata.")
    for k,v in pairs(self.persistdata) do
        print(k)
        if type(v) == "table" then
            print(v)
            for a,b in pairs(v) do
                print("Value2" .. b)
            end
        end
    end

    -- This is a sample feat for testing.
    AddFeat("sample_feat", "Sample Feat", "Sample Feat Description")
end

AddGlobalClassPostConstruct("playerprofile", "PlayerProfile", patch_feats)