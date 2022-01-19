local hud = {}

local hud1 = Graphics.loadImageResolved "devkit/hud1.png"
local hud2 = Graphics.loadImageResolved "devkit/hud2.png"
local hud3 = Graphics.loadImageResolved "devkit/hud3.png"

local itembox = Graphics.loadImageResolved "devkit/itembox.png"
local clover = Graphics.loadImageResolved "devkit/clover.png"

local textplus = require 'textplus'
local font =  textplus.loadFont("textplus/font/2.ini")

local coinAdd = {}

local function renderCoins(priority)
	Graphics.drawBox{texture = hud1, x = 32, y = 32, priority = priority}
	Graphics.drawBox{texture = Graphics.sprites.hardcoded['33-2'].img, x = 32 + 8, y = 32 + 8, priority = priority}	
	
	local count = mem(0x00B2C5A8, FIELD_WORD)
	
	textplus.print{
		text = "x " .. count,
		
		x = 32 + 32,
		y = 32 + 8,
		
		font = font,
		xscale = 2,
		yscale = 2,
		priority = priority,
	}
end

local function renderScore(priority)
	Graphics.drawBox{texture = hud2, x = 800 - hud2.width - 32, y = 32, priority = priority}
	
	local count = SaveData._basegame.hud.score
	count = string.format("%08d", count)
	
	textplus.print{
		text = count,
		
		x = 800 - hud2.width - 64,
		y = 32 + 8,
		
		xscale = 2,
		yscale = 2,
		
		font = font,
		priority = priority,
	}
end

local function renderItembox(idx, priority)
	Graphics.drawBox{texture = itembox, x = 400 - 26, y = 32, priority = priority}
	
	local p = Player(idx)
	
	if p.reservePowerup > 0 then
		if Graphics.sprites.npc[p.reservePowerup].img then
			Graphics.drawBox{
				texture = Graphics.sprites.npc[p.reservePowerup].img, 
				
				x = (400 - 26) + (56 - 32) / 2, 
				y = 32 + (56 - 32) / 2, 
				sourceWidth = 32,
				sourceHeight = 32,
				
				priority = priority
			}
		end
	end
end

local function renderClovers(priority)
	Graphics.drawBox{texture = hud3, x = 32, y = 64, priority = priority}
	Graphics.drawBox{texture = clover, x = 32 + 4, y = 64 + 2, priority = priority}
	
	local count = SaveData.cloversCount or 0
	
	textplus.print{
		text = "x " .. count,
		
		x = 32 + 32,
		y = 64 + 8,
		
		font = font,
		xscale = 2,
		yscale = 2,
		priority = priority,
	}
end

local oldCoinCount = mem(0x00B2C5A8, FIELD_WORD)

Graphics.overrideHUD(function(idx, priority, isSplit)
	local c = Camera(idx)
	
	renderCoins(priority)
	renderScore(priority)
	renderItembox(idx, priority)
	-- renderStars(priority)
	renderClovers(priority)
	
	local oldoldCount = oldCoinCount 
	
	if mem(0x00B2C5A8, FIELD_WORD) ~= oldCoinCount then
		oldCoinCount = mem(0x00B2C5A8, FIELD_WORD)
		
		coinAdd[#coinAdd + 1] = {count = mem(0x00B2C5A8, FIELD_WORD) - oldoldCount, yscale = 2, alpha = 0.25, y = 0}
	end
	
	for k,v in ipairs(coinAdd) do
		local count = v.count
		
		local c = 0.005
		
		if v.alpha > 0 then
			v.alpha = v.alpha - c
		end	
		
		v.y = v.y - 1.25
		v.yscale = v.yscale + 0.01
		
		textplus.print{
			text = '+ ' .. count,
			
			x = 32 + 32,
			y = (32 + 8) + v.y,
			
			font = font,
			xscale = v.yscale,
			yscale = v.yscale,	
			
			priority = priority,
			color = {0, 1, 0, v.alpha},
		}
		
		if v.alpha < 0 then
			table.remove(coinAdd, k)
		end	
	end
end)

return hud