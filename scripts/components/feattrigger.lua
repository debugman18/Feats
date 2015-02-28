-- PersistentData module stuff.
local PersistentData = require "persistentdata"
local Data = PersistentData("FeatsData")

local FeatTrigger = Class(function(self, inst)
    self.inst = inst
end)

-- We could just do UnlockFeat, or we could do an interesting callback.
function FeatTrigger:Trigger(keyname, callback)
    UnlockFeat(keyname)    
    if callback then
        callback()
    end
end

return FeatTrigger

