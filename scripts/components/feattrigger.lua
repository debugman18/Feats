-- Import our modenv.
local modenv = require "feats.modenv"

local FeatTrigger = Class(function(self, inst)
    self.inst = inst
end)

-- We could just do UnlockFeat, UnhideFeat, and/or we could do an interesting callback.
function FeatTrigger:Trigger(keyname, onlyunhide, callback)
	if not onlyunhide then
    	modenv.LockFeat(keyname, callback, false)
    else
    	modenv.HideFeat(keyname, callback, false)
    end
end

-- We could just do LockFeat, HideFeat, and/or we could do an interesting callback.
function FeatTrigger:Untrigger(keyname, onlyhide, callback)
	if not onlyhide then
    	modenv.LockFeat(keyname, callback, true)
    else
    	modenv.HideFeat(keyname, callback, true)
    end
end

-- Unlock all feats.
function FeatTrigger:TriggerAll()
    modenv.UnlockAllFeats()
end

return FeatTrigger

