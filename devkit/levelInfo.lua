local levelInfo = {}

local function insert(name, realName, usedMusic)
	levelInfo[name] = {name = (realName or name), music = usedMusic}
end

insert('Cobble Canyon', nil)

function levelInfo.get(name)
	local name = name or Level.filename():gsub('.lvlx', '')
	
	return levelInfo[name]
end

setmetatable(levelInfo, {__index = function(self, key)
	rawset(self, key, {name = Level.filename():gsub('.lvlx', '')})
	
	return rawget(self, key)
end})

return levelInfo