import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animator"
import "obstacles"
import "player"

local pd = playdate
local gfx = pd.graphics

function scroll(level)
    local speed = 1
    for i in pairs(level) do
        if level[i] and level[i]:getTag() == 2 or (level[i]:getTag() == 1 and level[i].grounded) then
            level[i]:moveTo(level[i].x - speed, level[i].y)
            if (level[i].type == 'spikeWall' and level[i].x < level.player.x) and not level[i].cleared then
                level.player.score += 1
                level[i].cleared = true
            end
            if level[i].x < -50 then
                level[i]:remove()
                level[i] = nil
            else
                local sprites = level[i]:overlappingSprites()
                for i = 1, #sprites do
                    if sprites[i]:getTag() == 1 then
                        local p = sprites[i]
                        p:moveTo(p.x - 1, p.y)
                    end
                end
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
    local num = 0
    local choice = math.floor(math.random() * 3)
    local first = true


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

        currentLevel[blockName] = Block(400, y, 50, 250 - y)
        currentLevel[spikeWallName] = SpikeWall(485, y)
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