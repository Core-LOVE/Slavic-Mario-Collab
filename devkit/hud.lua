local hud = {}

local bosses = {}

local hud1 = Graphics.loadImageResolved "devkit/hud1.png"
local hud2 = Graphics.loadImageResolved "devkit/hud2.png"
local hud3 = Graphics.loadImageResolved "devkit/hud3.png"

local itembox = Graphics.loadImageResolved "devkit/itembox.png"
local heart = Graphics.loadImageResolved 'devkit/heart.png'

local clover = Graphics.loadImageResolved "devkit/clover.png"
local coin = Graphics.loadImageResolved "devkit/coin.png"

local textplus = require 'textplus'
local font =  textplus.loadFont("textplus/font/2.ini")

local starcoin

local coinAdd = {}

local function renderCoins(priority)
	Graphics.drawBox{texture = hud1, x = 32, y = 32, priority = priority}
	Graphics.drawBox{texture = coin, x = 32 + 8, y = 32 + 8, priority = priority}	
	
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

local function renderHearts(priority)
	local count = player.Hearts
	
	local x = (400 - 26)
	local y = 48
	
	local dx = -24
	
	for i = 1, 3 do
		local c
		
		if count < i then
			c = {0.5, 0.5, 0.5, 0.5}
		end
		
		Graphics.drawBox{
			texture = heart,
			
			x = x + dx,
			y = y,
			
			color = c or {1, 1, 1, 1},
			priority = priority
		}
		
		dx = dx + heart.width + 2
	end
end

local function rect(x, y, w, h, c, p)
	Graphics.drawBox{
		x = x, y = y, width = w, height = h, color = c, priority = p,
	}
end

local function renderBossHP(priority)
	local x = 800 - 128
	local y = 600 - 48
	
	local dy = 0
	
	for k,v in ipairs(bosses) do
		local amount = v.amount
		local percent = math.floor((amount / v.max) * 100)
		
		local y = (y + dy)
		
		rect(x - 8, y - 8, 116, 48, Color.black .. 0.5, priority)
		
		if v.icon then
			Graphics.drawBox{
				texture = v.icon,
				
				x = x - v.icon.width,
				y = y,
				
				priority = priority,
			}
		end
		
		textplus.print{
			text = ("HP:" .. percent .. '%'),
			
			x = x,
			y = y,
			
			font = font,
			xscale = 2,
			yscale = 2,
			priority = priority,
		}
		
		rect(x + 2, y + 18, 100, 8, Color.black, priority)
		rect(x, y + 16, percent, 8, Color.red, priority)

		dy = dy - 64
	end
	
	bosses = {}
end

local starcoinImg = Graphics.loadImageResolved('devkit/starcoin.png')

local function validCoin(t, i)
	return t[i] and (t.alive[i])
end

local function renderStarcoins(priority)
	if not starcoin then return end
	
	local t = starcoin.getLevelList()
	
	if not t then return end
	
	local x = 32
	local y = 96
		
	for i = 1, t.maxID do
		local col = {0.5, 0.5, 0.5, 0.5}
		
		if t[i] ~= 0 then
			col = nil
		end
		
		Graphics.drawBox{
			texture = starcoinImg,
			
			x = x,
			y = y,
			
			color = col,
		}
		
		x = x + starcoinImg.width + 2
		
		if i % 5 == 0 then
			y = y + starcoinImg.height + 2
			x = 32
		end
	end
end

local oldCoinCount = mem(0x00B2C5A8, FIELD_WORD)

local noItembox = {
	[3] = true,
	[4] = true,
	[5] = true,
}

Graphics.overrideHUD(function(idx, priority, isSplit)
	local c = Camera(idx)
	
	renderCoins(priority)
	renderScore(priority)
	renderBossHP(priority)
	renderStarcoins(priority)
	
	if not noItembox[player.character] then
		renderItembox(idx, priority)
	else
		renderHearts(priority)
	end
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

local x = ((400 - 26) + (56 - 32) / 2)
local y = (32 + (56 - 32) / 2)

function hud.onInputUpdate()
	if player.keys.dropItem == KEYS_PRESSED and player.reservePowerup > 0 then
		SFX.play(11)
		
		local dropNpc = NPC.spawn(player.reservePowerup, x + camera.x, y + camera.y)
		dropNpc:mem(0x138, FIELD_WORD, 2)
		
		player.reservePowerup = 0
		player.keys.dropItem = false
	end
end

function hud.showBossHP(args)
	bosses[#bosses + 1] = args
end

function hud.onInitAPI()
	registerEvent(hud, 'onStart')
	registerEvent(hud, 'onInputUpdate')
	
	starcoin = require("npcs/ai/starcoin")
end

return hud