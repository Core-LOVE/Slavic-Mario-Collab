local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local chucks = require("npcs/ai/chucks")

local chessingChuck = {}
local npcID = NPC_ID;

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

local chessingChuckSettings = {
	id = npcID, 
	gfxwidth = 60, 
	gfxheight = 54, 
	width = 32, 
	height = 48, 
	gfxoffsetx=-16,
	frames = 5,
	framespeed = 8, 
	framestyle = 1,
	score = 0,
	nofireball = 0,
	noyoshi = 1,
	spinjumpsafe = true,
	npconhit = 311,
}

local configFile = npcManager.setNpcSettings(chessingChuckSettings);

npcManager.registerHarmTypes(npcID, 	
{HARM_TYPE_JUMP, HARM_TYPE_FROMBELOW, HARM_TYPE_NPC, HARM_TYPE_HELD, HARM_TYPE_TAIL, HARM_TYPE_SPINJUMP, HARM_TYPE_SWORD, HARM_TYPE_LAVA}, 
{[HARM_TYPE_JUMP]=73,
[HARM_TYPE_FROMBELOW]=172,
[HARM_TYPE_NPC]=172,
[HARM_TYPE_HELD]=172,
[HARM_TYPE_TAIL]=172,
[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}});

-- Defines
local STATE_THINK = 0;
local STATE_REACH = 1;
local STATE_STROKE = 2;
local STATE_LOOK = 3;

-- Final setup
local function hurtFunction (v)
	v.ai2 = 0;
end

local function hurtEndFunction (v)
	v.data._basegame.frame = 0;
end

function chessingChuck.onInitAPI()
	npcManager.registerEvent(npcID, chessingChuck, "onTickEndNPC");
	chucks.register(npcID, hurtFunction, hurtEndFunction);
end

--*********************************************
--                                            *
--              Chessing CHUCK                *
--                                            *
--*********************************************

function chessingChuck.onTickEndNPC(v)
	if Defines.levelFreeze then return end;
	
	local data = v.data._basegame
	
	-- initializing
	if (v:mem(0x12A, FIELD_WORD) <= 0 --[[or v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL)]] or v:mem(0x138, FIELD_WORD) > 0) then
		v.ai1 = configFile.health; -- Health
		data.state = STATE_THINK
		v.ai2 = 0
		
		v.animationFrame = npcutils.getFrameByFramestyle(v, {
			frame = 0,
			frames = configFile.frames
		})
		return
	end
	if (data.exists == nil) then
		v.ai1 = configFile.health;
		data.exists = 0;
		data.frame = 0;
	end
	
	-- timer start
	
	if data.state == STATE_THINK then
		data.frame = 0;
		v.ai3 = 0
		v.ai4 = 0
		v.ai2 = v.ai2 + 1;
		if v.ai2 >= RNG.random(192,448) then
			data.chessState = RNG.random()
			if data.chessState <= 0.25 then
				data.state = STATE_REACH
			elseif data.chessState > 0.25 and data.chessState <= 0.50 then
				data.state = STATE_LOOK
			else
				data.state = STATE_STROKE
			end
		v.ai2 = 0
		end
	elseif data.state == STATE_STROKE then
		v.ai3 = v.ai3 + 1
		data.frame = math.floor(v.ai3 / 12) % 2;
		local rnd = RNG.randomInt(47,71)
		if v.ai3 == rnd then	
			data.state = STATE_THINK
		elseif v.ai3 > 71 then
			data.state = STATE_THINK
		end
	elseif data.state == STATE_REACH then
		v.ai4 = v.ai4 + 1
		if v.ai4 < 32 then
			v.ai3 = v.ai3 + 1
		else
			v.ai3 = v.ai3 - 1
		end
		if v.ai3 < 0 then
			data.state = STATE_THINK
		end
		if v.ai3 <= 8 then 
			data.frame = 3;
		else
			data.frame = 2;
		end
	else
		data.frame = 4;
		v.ai3 = v.ai3 + 1
		if v.ai3 >= 128 then
			data.state = STATE_THINK
		end
	end
	-- animation controlling
	v.animationFrame = npcutils.getFrameByFramestyle(v, {
		frame = data.frame,
		frames = configFile.frames
	});
end

function chessingChuck.onDrawNPC(v)
	if not Defines.levelFreeze then
		local data = v.data._basegame
		if not data.frame then return end
		v.animationFrame = data.frame + directionOffset[v.direction];
	end
end

return chessingChuck;