local lockInput = false
local ending = false

local transition = {
	state = 0,
	timer = 0,
	
	width = 0,
	screen = 0,
	
	frame = 0,
	maxFrame = 9,
	y = -24,
	x = 0,
}

function onInputUpdate()
	if not lockInput then return end
	
	for k in pairs(player.keys) do
		player.keys[k] = false
	end
end

function onEvent(n)
	if n == 'appear' then
		SFX.play 'appear.ogg'
		lockInput = true
		
		Audio.SeizeStream(player.section)
		Audio.MusicStop()
	elseif n == "dialogue" then
		Audio.MusicOpen(Misc.levelFolder() .. "rouxls.ogg")
		Audio.MusicPlay()
		
		littleDialogue.create{
			text = "<portrait rules>Ye WORMES THOUGHT THAT I, THE GREAT ROUXLS KAARD COULDE BE CONSTRAINEST TO BUT ONE GAMEN?!",
			
			style = 'dr',
		}
	elseif n == "dialogue2" then
		Audio.MusicStop()
		
		littleDialogue.create{
			text = "<portrait rules 2>Waite is thate mario gamen?<page>I think<page>I think I need to checke oute Kris in Chapter Three.<page>Alls Well That Ends Well!",
			
			style = 'dr',
		}
	elseif n == "disappear" then
		ending = true
		SFX.play 'slidewhist.wav'
	end
end

function onTickEnd()
	if not lockInput then return end
	
	if transition.state == 0 then
		transition.timer = transition.timer + 1
	end
	
	if transition.timer > 64 and transition.state == 0 then
		transition.state = 1
		transition.timer = 0
	end
	
	if transition.state == 0 then
		transition.width = transition.width + 24
		
		if transition.frame < transition.maxFrame - 1 then
			transition.frame = transition.frame + 0.15
		end
		
		if transition.y < 0 then
			transition.y = transition.y + 1
		end
		
		if transition.screen < 1 then
			transition.screen = transition.screen + 0.05
		end
	elseif transition.state == 1 then
		transition.screen = transition.screen - 0.05
		transition.width = transition.width - 12
	end
	
	transition.width = math.clamp(transition.width, -24, 150)
	
	if ending then
		transition.x = transition.x + 12
		transition.timer = transition.timer + 1
		
		if transition.timer > 64 then
			Audio.MusicOpen(Misc.levelFolder() .. "Caveman.ogg")
			Audio.MusicPlay()
		
			lockInput = false
			ending = false
			
			transition.timer = 0
		end
	end
end

local function drawBar(t, bound, w)
	if t.width <= -24 then return end
	
	local w = w or 0
	
	Graphics.drawBox{
		x = (bound.left + 400) - (t.width + w) * 0.5,
		y = bound.top,
		width = t.width + w,
		height = 600,
		
		sceneCoords = true,
		color = Color.white .. 0.6,
	}
end

local rouxls = Graphics.loadImage 'rouxls.png'

function onCameraDraw()
	if not lockInput then return end

	local t = transition
	local bound = Section(player.section).boundary
	
	Graphics.drawScreen{
		color = Color.black .. t.screen * 0.5,
	}
	
	drawBar(t, bound)
	drawBar(t, bound, 16)
	drawBar(t, bound, 32)
	drawBar(t, bound, 64)
	drawBar(t, bound, 96)
	
	local f = math.floor(t.frame)
	local h = rouxls.height / t.maxFrame
	
	Graphics.drawBox{
		texture = rouxls,
		
		x = (bound.left + 400) - (rouxls.width * 0.5) + t.x,
		y = (bound.top + 358) + t.y,
		
		sourceY = h * f,
		sourceHeight = h,
		
		sceneCoords = true,
	}
end

function onOptimize()
	for k,v in ipairs(Section.get()) do
		if v.backgroundID == 11 then
			local layer = v.background:get("bg3")
			layer.hidden = not layer.hidden
		end
	end
end
