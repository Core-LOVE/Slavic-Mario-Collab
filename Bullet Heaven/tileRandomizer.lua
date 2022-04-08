local tileRandomizer = {}

local rng = RNG.new(133)

local lists = {}
local ids = {}

function tileRandomizer.register(source, targets)
    table.insert(ids, source)
    lists[source] = targets
end

function tileRandomizer.onInitAPI()
    registerEvent(tileRandomizer, "onStart")
end

function tileRandomizer.onStart()
    for k,v in ipairs(Block.get(ids)) do
        if rng:randomInt(1, 15) == 1 then
            v.id = rng:irandomEntry(lists[v.id])
        end
    end
end

return tileRandomizer