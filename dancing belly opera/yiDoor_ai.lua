--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local yiDoor = {}


yiDoor.sharedSettings = {
	gfxwidth = 64,
	gfxheight = 64,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 64,
	height = 64,
	
	frames = 5,
	framestyle = 0,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	ignorethrownnpcs = true,


    enterSound = Misc.resolveSoundFile("yiDoor_enter"),
    closeSound = Misc.resolveSoundFile("yiDoor_close"),

    renderscale = 0.5,


    openRotationSpeed = 1.5,
    openMaxRotation = 125,

    closeRotationAcceleration = 0.75,

    playerFadeTime = 24,

    endWaitTime = 24,

    closeEarthquake = 3,
}


yiDoor.idList = {}
yiDoor.idMap  = {}


function yiDoor.register(npcID)
    npcManager.registerEvent(npcID, yiDoor, "onTickEndNPC")
    npcManager.registerEvent(npcID, yiDoor, "onDrawNPC")

    table.insert(yiDoor.idList,npcID)
    yiDoor.idMap[npcID] = true
end


local STATE = {
    NORMAL          = 0,
    OPEN            = 1,
    PLAYER_FADE_OUT = 2,
    PLAYER_FADE_IN  = 3,
    CLOSE           = 4,
    END_WAIT        = 5,
    FINISHED        = 6,
}

local EXIT_STYLE = {
    DO_NOTHING = 0,
    CLOSE_AFTER = 1,
    OPEN_SIMULTANEOUSLY = 2,
}


local unmuteDoorSound = false
local defaultDoorSFX = 46

local playersInteractingWithDoor = {}


local function handleAnimation(v,data,config)
    local singleFrame = (config.frames - 2) / 3
    local frame = math.floor(data.animationTimer / config.framespeed) % singleFrame

    if data.entranceWarp ~= nil and data.entranceWarp.isValid then
        if data.entranceWarp.locked then
            frame = frame + singleFrame
        end
    else
        frame = frame + singleFrame*2
    end

    data.animationTimer = data.animationTimer + 1

    v.animationFrame = npcutils.getFrameByFramestyle(v,{frame = frame})
end


local function getEntranceWarp(v)
    for _,warp in ipairs(Warp.getIntersectingEntrance(v.x,v.y,v.x + v.width,v.y + v.height)) do
        if warp.warpType == 2 then
            return warp
        end
    end

    return nil
end

local function getExitWarp(v)
    for _,warp in ipairs(Warp.getIntersectingExit(v.x,v.y,v.x + v.width,v.y + v.height)) do
        if warp.warpType == 2 then
            return warp
        end
    end

    return nil
end

local function getExitFromWarp(warp)
    for _,door in NPC.iterateIntersecting(warp.exitX,warp.exitY,warp.exitX+warp.exitWidth,warp.exitY+warp.exitHeight) do
        if not door.isGenerator then
            return door
        end
    end

    return nil
end


local function getEntranceHitbox(warp)
    return Colliders.Box(warp.entranceX,warp.entranceY,warp.entranceWidth,warp.entranceHeight)
end


local function initialise(v,data)
    data.initialized = true

    data.state = STATE.NORMAL
    data.timer = 0

    data.angle = 0

    data.playerFade = 0


    data.animationTimer = 0

    data.entranceWarp = getEntranceWarp(v)
    data.exitWarp = getExitWarp(v)

    if data.entranceWarp ~= nil then
        data.exitDoor = getExitFromWarp(data.entranceWarp)
    else
        data.exitDoor = nil
    end

    data.openingPlayer = nil

    data.isExitDoor = false
end


function yiDoor.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

    local config = NPC.config[v.id]
    local settings = v.data._settings

	if not data.initialized then
		initialise(v,data)
	end


    npcutils.applyLayerMovement(v)


    if data.entranceWarp ~= nil and data.entranceWarp.isValid then
        for _,p in ipairs(Player.get()) do
            if p.forcedState == FORCEDSTATE_DOOR and p.forcedTimer >= 3 and data.state == STATE.NORMAL and data.entranceWarp.idx+1 == p:mem(0x15E,FIELD_WORD) then
                data.state = STATE.OPEN
                data.timer = 0

                data.openingPlayer = p

                data.isExitDoor = false

                table.insert(playersInteractingWithDoor,{p,v})

                if settings.exitStyle == EXIT_STYLE.OPEN_SIMULTANEOUSLY and data.exitDoor ~= nil and data.exitDoor.isValid then
                    local exitConfig = NPC.config[data.exitDoor.id]
                    local exitData = data.exitDoor.data

                    if exitData.state == STATE.NORMAL then
                        exitData.state = STATE.OPEN
                        exitData.timer = 0

                        exitData.openingPlayer = p

                        exitData.isExitDoor = true
                    end
                end

                SFX.play(config.enterSound)
            elseif not Audio.sounds[defaultDoorSFX].muted and Colliders.collide(Colliders.getSpeedHitbox(p),getEntranceHitbox(data.entranceWarp)) then
                Audio.sounds[defaultDoorSFX].muted = true
                unmuteDoorSound = true
            end
        end
    end

    if data.openingPlayer ~= nil and data.openingPlayer.isValid then
        if data.openingPlayer.forcedState == FORCEDSTATE_DOOR then
            if data.state == STATE.FINISHED or (settings.exitStyle == EXIT_STYLE.OPEN_SIMULTANEOUSLY and data.state == STATE.CLOSE) then
                data.openingPlayer.forcedTimer = math.max(29,data.openingPlayer.forcedTimer)
            else
                data.openingPlayer.forcedTimer = 3
            end
        else
            data.openingPlayer = nil
        end
    end

    if data.state == STATE.OPEN then
        data.angle = math.min(config.openMaxRotation,data.angle + config.openRotationSpeed)

        if data.angle >= config.openMaxRotation then
            data.state = STATE.PLAYER_FADE_OUT
            data.timer = 0
        end
    elseif data.state == STATE.PLAYER_FADE_OUT then
        data.timer = data.timer + 1
        data.playerFade = math.clamp(data.timer / config.playerFadeTime)

        if data.playerFade >= 1 then
            if settings.exitStyle == EXIT_STYLE.OPEN_SIMULTANEOUSLY or data.isExitDoor then
                data.state = STATE.PLAYER_FADE_IN

                if not data.isExitDoor and data.openingPlayer ~= nil and data.openingPlayer.isValid and data.entranceWarp ~= nil and data.entranceWarp.isValid then
                    data.openingPlayer:teleport(
                        data.entranceWarp.exitX + data.entranceWarp.exitWidth*0.5 - data.openingPlayer.width*0.5,
                        data.entranceWarp.exitY + data.entranceWarp.exitHeight - data.openingPlayer.height
                    )
                end
            else
                data.state = STATE.CLOSE
            end

            data.timer = 0
        end
    elseif data.state == STATE.PLAYER_FADE_IN then
        data.timer = data.timer + 1
        data.playerFade = math.clamp(1 - (data.timer / config.playerFadeTime))

        if data.playerFade <= 0 then
            data.state = STATE.CLOSE
            data.timer = 0
        end
    elseif data.state == STATE.CLOSE then
        data.timer = data.timer + 1

        data.angle = math.max(0,data.angle - data.timer*config.closeRotationAcceleration)

        if data.angle <= 0 then
            if data.openingPlayer ~= nil and data.openingPlayer.isValid then
                data.state = STATE.END_WAIT
            else
                data.state = STATE.NORMAL
            end

            data.timer = 0

            SFX.play(config.closeSound)

            Defines.earthquake = config.closeEarthquake
        end
    elseif data.state == STATE.END_WAIT then
        data.timer = data.timer + 1

        if data.timer >= config.endWaitTime then
            data.state = STATE.FINISHED
            data.timer = 0
        end
    elseif data.state == STATE.FINISHED then
        if data.openingPlayer == nil or not data.openingPlayer.isValid then
            data.state = STATE.NORMAL
            data.timer = 0

            data.playerFade = 0

            if settings.exitStyle == EXIT_STYLE.CLOSE_AFTER and data.exitDoor ~= nil and data.exitDoor.isValid and not data.isExitDoor then
                local exitConfig = NPC.config[data.exitDoor.id]
                local exitData = data.exitDoor.data

                if not exitData.initialized then
                    initialise(data.exitDoor,exitData)
                end

                if exitData.state == STATE.NORMAL then
                    exitData.state = STATE.CLOSE
                    exitData.timer = 0

                    exitData.angle = exitConfig.openMaxRotation

                    data.exitDoor:mem(0x124,FIELD_BOOL,true)
                    data.exitDoor.despawnTimer = 180
                end
            end
        end
    end

	handleAnimation(v,data,config)
end


local buffer = Graphics.CaptureBuffer(128,128)

function yiDoor.onDrawNPC(v)
    if v.despawnTimer <= 0 or v.isHidden then return end

    local config = NPC.config[v.id]
    local data = v.data

    local settings = v.data._settings


    if not data.initialized then
        initialise(v,data)
    end


    local priority = (config.priority and -15) or -76

    local image = Graphics.sprites.npc[v.id].img

    if image == nil then
        return
    end


    if data.angle ~= nil and data.angle ~= 0 then
        buffer:clear(priority)
        --Graphics.drawBox{x = 0,y = 0,width = buffer.width,height = buffer.height,color = Color.red,priority = priority,target = buffer}

        -- Draw back
        Graphics.drawBox{
            texture = image,priority = priority - 0.2,sceneCoords = true,
            x = v.x + v.width*0.5 + config.gfxoffsetx - config.gfxwidth*0.5,y = v.y + v.height - config.gfxheight + config.gfxoffsety,
            width = config.gfxwidth,height = config.gfxheight,
            sourceWidth = config.gfxwidth,sourceHeight = config.gfxheight,
            sourceX = 0,sourceY = config.gfxheight*(config.frames - 2),
        }


        for side = 0, 1 do
            local frontWidth = config.gfxwidth * 0.5 * math.cos(math.rad(data.angle))
            local sideWidth  = config.gfxwidth * 0.5 * math.sin(math.rad(data.angle))

            local direction = (-1 + side*2)

            local farX = buffer.width*0.5 + direction*config.gfxwidth*0.5*config.renderscale

            local frontX = farX - frontWidth*config.renderscale*side
            local frontY = buffer.height*0.5 - config.gfxheight*0.5*config.renderscale

            local sideX = farX + (frontWidth*-direction - sideWidth*0.5)*config.renderscale
            local sideY = frontY

            -- Draw front
            Graphics.drawBox{
                texture = image,target = buffer,priority = priority,
                x = frontX,y = frontY,width = frontWidth*config.renderscale,height = config.gfxheight*config.renderscale,
                sourceWidth = config.gfxwidth*0.5,sourceHeight = config.gfxheight,
                sourceX = config.gfxwidth*0.5*side,sourceY = v.animationFrame*config.gfxheight,
            }

            -- Draw side
            Graphics.drawBox{
                texture = image,target = buffer,priority = priority,
                x = sideX,y = sideY,width = sideWidth*config.renderscale,height = config.gfxheight*config.renderscale,
                sourceWidth = config.gfxwidth*0.5,sourceHeight = config.gfxheight,
                sourceX = config.gfxwidth*0.5*side,sourceY = config.gfxheight*(config.frames - 1),
            }
        end

        local fullWidth  = buffer.width  / config.renderscale
        local fullHeight = buffer.height / config.renderscale

        Graphics.drawBox{
            texture = buffer,sceneCoords = true,priority = priority,
            x = v.x + v.width*0.5 + config.gfxoffsetx - fullWidth*0.5,y = v.y + v.height - config.gfxheight*0.5 + config.gfxoffsety - fullHeight*0.5,
            width = fullWidth,height = fullHeight,
            sourceWidth = buffer.width,sourceHeight = buffer.height,
        }

        --Graphics.drawBox{texture = buffer,priority = priority,x = 0,y = 96}
    else
        npcutils.drawNPC(v,{priority = priority})
    end

    npcutils.hideNPC(v)
end


function yiDoor.onTickEnd()
    if unmuteDoorSound then
        Audio.sounds[defaultDoorSFX].muted = false
        unmuteDoorSound = false
    end
end

function yiDoor.onDraw()
    for i = #playersInteractingWithDoor, 1, -1 do
        local data = playersInteractingWithDoor[i]
        local p    = data[1]
        local door = data[2]

        if p.isValid and door.isValid then
            if p.forcedState == FORCEDSTATE_DOOR then
                local doorData = door.data

                local priority = (doorData.playerFade > 0 and -76.1) or -75.9

                if door.data._settings.exitStyle == EXIT_STYLE.OPEN_SIMULTANEOUSLY and doorData.state >= STATE.PLAYER_FADE_IN then
                    p.frame = 1
                end
                
                p:render{priority = priority,color = Color.white.. (1 - doorData.playerFade)}

                p.forcedState = FORCEDSTATE_INVISIBLE
            else
                if p.frame == 13 then
                    p.frame = 1
                end

                table.remove(playersInteractingWithDoor,i)
            end
        else
            table.remove(playersInteractingWithDoor,i)
        end
    end
end

function yiDoor.onDrawEnd()
    for i = #playersInteractingWithDoor, 1, -1 do
        local data = playersInteractingWithDoor[i]
        local p    = data[1]
        local door = data[2]

        if p.isValid and p.forcedState == FORCEDSTATE_INVISIBLE then
            p.forcedState = FORCEDSTATE_DOOR
        end
    end
end


function yiDoor.onInitAPI()
    registerEvent(yiDoor,"onTickEnd")
    registerEvent(yiDoor,"onDraw")
    registerEvent(yiDoor,"onDrawEnd")
end


return yiDoor