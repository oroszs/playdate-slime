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
    local speed = 1
    for i in pairs(level) do
        if level[i] and level[i]:getTag() == 2 or level[i]:getTag() == 1 or (level[i]:getTag() == 3 and level[i].grounded) then
            level[i]:moveTo(level[i].x - speed, level[i].y)
            --[[
            local sprites = level[i]:overlappingSprites()
            for j = 1, #sprites do
                if sprites[j]:getTag() == 3 then
                    local p = sprites[j]
                    if p.x < level[i].x and (p.y > (level[i].y - p.w - 1)) then
                        --p:moveTo(p.x - speed, p.y)
                        p.dx = -3
                        p.dy = -5
                    end
                end
            end
            ]]
            if (level[i].type == 'SpikeWall' and level[i].x < level.player.x) and not level[i].cleared and level.player.alive then
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

function walls(allWalls)
    ---screen dimensions: 400 x 240
    local wallWidth = 5
    local screenWidth = 400
    local screenHeight = 240

    local bottomWall = Wall(0, screenHeight - wallWidth, screenWidth, wallWidth)
    bottomWall.type = "Floor"
    bottomWall:setTag(1)

    if allWalls then
        local rightWall = Wall(screenWidth - wallWidth, 0, wallWidth, screenHeight)
        local leftWall = Wall(0, 0, wallWidth, screenHeight)
        local topWall = Wall(0, 0, screenWidth, wallWidth)
        topWall.type = "Ceiling"
    end

    return bottomWall

end

function level(player)
    local currentLevel = {}
    local floor = walls()
    currentLevel.player = player
    currentLevel.floor = floor
    local num = 1
    local choice = math.floor(math.random() * 3)
    local first = true
    currentLevel.block0 = Block(85, 225, 50, 250 - 225)
    currentLevel.block0.type = nil

    function spawnBlock()

        if not first then
            local adjustment = math.floor(math.random() * 3) - 1
            choice += adjustment
            if choice > 6 then choice = 6
            elseif choice < 0 then choice = 0
            end
        end
        local blockName = 'block' .. num
        local spikeWallName = 'spikeWall' .. num
        local movingBlockName = 'movingBlock' .. num
        num += 1

        local y

        if choice == 0 then
            y = 225
        elseif choice == 1 then
            y = 200
        elseif choice == 2 then
            y = 175
        elseif choice == 3 then
            y = 150
        elseif choice == 4 then
            y = 125
        elseif choice == 5 then
            y = 100
        elseif choice == 6 then
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

        if spikeCheck < 3 then currentLevel[spikeWallName] = SpikeWall(485, y) end
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