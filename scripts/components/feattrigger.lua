-- Import our modenv.
local modenv = require "feats.modenv"

local FeatTrigger = Class(function(self, inst)
    self.inst = inst
end)

-- We could just do UnlockFeat, UnhideFeat, and/or we could do an interesting callback.
function FeatTrigger:Trigger(keyname, onlyunhide, callback)
	if not onlyunhide then
    	modenv.UnlockFeat(keyname, callback)
    else
    	modenv.UnhideFeat(keyname, callback)
    end
end

-- We could just do LockFeat, HideFeat, and/or we could do an interesting callback.
function FeatTrigger:Untrigger(keyname, onlyhide, callback)
	if not onlyhide then
    	modenv.LockFeat(keyname, callback)
    else
    	modenv.HideFeat(keyname, callback)
    end
end

return FeatTrigger

