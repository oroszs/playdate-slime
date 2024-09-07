import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animator"
import "obstacles"
import "player"

local pd = playdate
local gfx = pd.graphics
local moving = false

function scroll(level)
    ---Tags---
    --- 1: Floor
    --- 2: Block, MovingBlock, SpikeBlockHolder
    --- 3: Player
    --- 4: Top and Bottom SpikeBlock
    local speed = 1
    for i in pairs(level) do
        if level[i] and level[i]:getTag() == 2 or level[i]:getTag() == 1 or (level[i]:getTag() == 3 and level[i].grounded) then
            level[i]:moveTo(level[i].x - speed, level[i].y)
            --if(level[i].type) then print("Scrolling " .. level[i].type) end
            if (level[i].type == 'SpikeWall' and (level[i].x + level[i].w) < level.player.x) and not level[i].cleared and level.player.alive then
                level.player.score += 1
                level[i].cleared = true
            end
            if (level[i].x < -50 and not level[i]:getTag() == 1) or (level[i].x < -500 and level[i]:getTag() == 1) then
                level[i]:remove()
                level[i] = nil
            end
        end
    end
end

function floor(first)
    ---screen dimensions: 400px x 240px
    local wallWidth = 5
    local screenWidth = 400
    local screenHeight = 240
    local xVal, yVal
    local height = 10

    if first then
        xVal = 0
    else
        xVal = screenWidth
    end

    yVal = screenHeight - wallWidth - height

    local floorObj = Wall(xVal, yVal, screenWidth, 250 - yVal)

    floorObj.type = "Floor"
    floorObj:setTag(1)

    return floorObj

end

function level(player)
    local currentLevel = {}
    currentLevel.player = player
    currentLevel.floor0 = floor(true)
    currentLevel.floor1 = floor(false)
    local num = 1
    local choice = math.floor(math.random() * 2)
    local first = true
    local yVal = 200
    currentLevel.block0 = Block(85, yVal, 50, 250 - yVal)
    currentLevel.block0.type = nil

    function spawnBlock()
        --print('Spawned!')
        if not first then
            local adjustment = math.floor(math.random() * 3) - 1
            choice += adjustment
            if choice > 4 then choice = 4
            elseif choice < 0 then choice = 0
            end
        end
        local blockName = 'block' .. num
        local spikeWallName = 'spikeWall' .. num
        local movingBlockName = 'movingBlock' .. num
        num += 1

        local y

        if choice == 0 then
            y = 175
        elseif choice == 1 then
            y = 150
        elseif choice == 2 then
            y = 125
        elseif choice == 3 then
            y = 100
        elseif choice == 4 then
            y = 75
        end

        local moveCheck = math.floor(math.random() * 2)

        if moveCheck == 0 and not moving then
            moving = true
            currentLevel[movingBlockName] = MovingBlock(400, y, 50, 250 - y + 50, 3000, 50)
        else
            currentLevel[blockName] = Block(400, y, 50, 250 - y)
            moving = false
        end

        local spikeCheck = math.floor(math.random() * 5)

        if spikeCheck < 3 then currentLevel[spikeWallName] = SpikeWall(485, y, 25) end
        first = false
    end

    return currentLevel

end

function bg()
    local backgroundImage = gfx.image.new("images/checkered-bg")
    local ditherType = gfx.image.kDitherTypeBurkes
    local radius = 2
    local numPasses = 1
    local blurredBG = backgroundImage:blurredImage(radius, numPasses, ditherType)
    local alpha = .5
    local fadedBG = blurredBG:fadedImage(alpha, ditherType)
    assert (fadedBG)
    gfx.sprite.setBackgroundDrawingCallback(
        function (x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            fadedBG:draw(0,0)
            gfx.clearClipRect()
        end
    )
end