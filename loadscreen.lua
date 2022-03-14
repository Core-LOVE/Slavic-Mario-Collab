local episodePath = _episodePath


-- The following code makes the loading screen slightly less restricted

local function exists(path)
	local f = io.open(path,"r")

	if f ~= nil then
		f:close()
		return true
	else
		return false
	end
end

Misc.resolveFile = (function(path)
	local inScriptPath = getSMBXPath().. "\\scripts\\".. path
	local inEpisodePath = episodePath.. path

	return (exists(path) and path) or (exists(inEpisodePath) and inEpisodePath) or (exists(inScriptPath) and inScriptPath) or nil
end)

Misc.resolveGraphicsFile = Misc.resolveFile -- good enough lol

-- Make require work better
local oldRequire = require

function require(path)
	local inScriptPath = getSMBXPath().. "\\scripts\\".. path.. ".lua"
	local inScriptBasePath = getSMBXPath().. "\\scripts\\base\\".. path.. ".lua"
	local inEpisodePath = episodePath.. path.. ".lua"

	local path = (exists(inEpisodePath) and inEpisodePath) or (exists(inScriptPath) and inScriptPath) or (exists(inScriptBasePath) and inScriptBasePath)
	assert(path ~= nil,"module '".. path.. "' not found.")

	return oldRequire(path)
end

-- classexpender stuff
function string.split(s, p, exclude, plain)
	if  exclude == nil  then  exclude = false; end;
	if  plain == nil  then  plain = true; end;

	local t = {};
	local i = 0;

	if(#s <= 1) then
		return {s};
	end

	while true do
		local ls,le = s:find(p, i, plain);  --find next split pattern
		if (ls ~= nil) then
			table.insert(t, string.sub(s, i,le-1));
			i = ls+1;
			if  exclude  then
				i = le+1;
			end
		else
			table.insert(t, string.sub(s, i));
			break;
		end
	end
	
	return t;
end

function table.clone(t)
	local rt = {};
	for k,v in pairs(t) do
		rt[k] = v;
	end
	setmetatable(rt, getmetatable(t));
	return rt;
end

function table.ishuffle(t)
	for i=#t,2,-1 do 
		local j = RNG.randomInt(1,i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function math.clamp(a,mi,ma)
	mi = mi or 0;
	ma = ma or 1;
	return math.min(ma,math.max(mi,a));
end



_G.lunatime = require("engine/lunatime")
_G.Color = require("engine/color")
_G.RNG = require("rng")

function lunatime.tick()
	return loadscreenTimer
end
function lunatime.drawtick()
	return loadscreenTimer
end
function lunatime.time()
	return lunatime.toSeconds(loadscreenTimer)
end
function lunatime.drawtime()
	return lunatime.toSeconds(loadscreenTimer)
end

local textplus = require 'textplus'
local font =  textplus.loadFont("textplus/font/6.ini")

local path = mem(0x00B2C61C, FIELD_STRING) .. "/"
local clover = Graphics.loadImage(path .. 'devkit/clover.png')

local x = (800 - 200) + 16
local y = 600 - 42

local t = 0

local str = 'Loading...'

local loadBox = Graphics.loadImage(path .. 'devkit/loadBox.png')
local loadImg
local loadAlpha = 1

-- local names = {
	-- ['prologue'] = 'Prologue',
	-- ['Deciduous forest'] = 'Deciduous Forest',
	-- ['chicky friendship'] = 'Chicky Friendship',
	-- ['shapeshifter'] = 'Shapeshifter',
	-- ['boogie boogie kitchen'] = "Boogie Boogie's Kitchen",
	
	-- ['Celestial islands'] = "Celestial Islands",
	-- ['majestic melody'] = 'Majestic Melody',
	-- ['sherif bun fortress'] = "Sherif Bun's Fortress",
	
	-- ['el norado'] = 'El Norado',
-- }

-- local authors = {
	-- ['prologue'] = 'Core',
	-- ['Cobble Canyon'] = 'UndeFin',
	-- ['Deciduous forest'] = 'Retro_games428',
	-- ['chicky friendship'] = 'Core',
	-- ['shapeshifter'] = 'Alex1479',
	-- ['boogie boogie kitchen'] = 'Core',
	
	-- ['Celestial islands'] = "Retro_games428",
	-- ['Aurora Garden'] = 'UndeFin',
	-- ['majestic melody'] = 'Core',
	-- ['Gloomy Heights'] = 'Greenlight',
	-- ['sherif bun fortress'] = 'Core',
	
	-- ['el norado'] = 'Core',
-- }

-- local no = {
	-- ['credits'] = true,
	-- ['worldmap'] = true,
-- }

function onDraw()
	-- loading img
	-- local name = mem(0xB2C5A4, FIELD_STRING):gsub('.lvlx', '')
	
	-- if name ~= "" then
		-- if loadAlpha > -1 then
			-- loadAlpha = loadAlpha - 0.05
		-- end
		
		-- loadImg = Graphics.loadImage(path .. 'devkit/loadscreen/' .. name .. '.png')
		
		-- if loadImg then
			-- Graphics.drawImage(loadImg, 400 - loadBox.width / 2, 300 - loadBox.height / 2)
			-- Graphics.drawImage(loadBox, 400 - loadBox.width / 2, 300 - loadBox.height / 2)
		-- end
		
		-- local levelName = names[name] or name
		
		-- if levelName and not no[levelName] then
			-- textplus.print{
				-- text = levelName,
				
				-- x = 400 - loadBox.width / 2,
				-- y = (300 + loadBox.height / 2) + 16,
				
				-- font = font,
				
				-- xscale = 2,
				-- yscale = 2,
			-- }	
		-- end
		
		-- if authors[name] then
			-- textplus.print{
				-- text = authors[name],
				
				-- x = 400 - loadBox.width / 2,
				-- y = (300 + loadBox.height / 2) + 32,
				
				-- font = font,
				
				-- color = Color.yellow,
				
				-- xscale = 1.5,
				-- yscale = 1.5,
			-- }	
		-- end
		
		-- Graphics.drawBox{
			-- x = 0,
			-- y = 0,
			-- width = 800,
			-- height = 600,
			
			-- color = Color.black .. loadAlpha,
			-- priority = 10,
		-- }
	-- end
	
	-- loading text
	t = t + 1
	
	local dy = math.cos(t / 8) * 8 
	
	Graphics.drawImage(clover, x - 32, y + dy)

	
	do
		local vx = 0
		
		local vx = 0
		
		for i = 1, #str do
			local vy = math.sin((t / 8) + i) * 2
			
			local c = str:sub(i, i)
			
			textplus.print{
				text = c,
				
				x = x + vx,
				y = y + 2 - vy,
				
				font = font,
				
				xscale = 2,
				yscale = 2,
				
				color = Color.green .. 0.1,
			}	
			
			vx = vx + 16
		end
		
		local vx = 0
		
		Graphics.drawBox{
			x = x,
			y = y,
				
			width = 400,
			height = 32,
				
			color = Color.black .. 0.5,
		}
		
		for i = 1, #str do
			local vy = math.sin((t / 8) + i) * 2
			
			local c = str:sub(i, i)
			
			textplus.print{
				text = c,
				
				x = x + vx,
				y = y + 2 + vy,
				
				font = font,
				
				xscale = 2,
				yscale = 2,
			}	
			
			vx = vx + 16
		end
	end
end

local fadeTime = 42
local cnt = fadeTime

local draw = onDraw
onDraw = function()
	draw()
	
	local alpha = (cnt / fadeTime)

	Graphics.drawBox{
		x = 0,
		y = 0,
		width = 800,
		height = 600,
		
		color = Color.black .. alpha,
	}
	cnt = cnt - 1
end