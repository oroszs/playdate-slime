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
        if level[i]:getTag() == 2 or (level[i]:getTag() == 1 and level[i].grounded) then
            level[i]:moveTo(level[i].x - speed, level[i].y)
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

function walls(allWalls)
    ---screen dimensions: 400 x 240
    local wallWidth = 5
    local screenWidth = 400
    local screenHeight = 240

    local bottomWall = Wall(0, screenHeight - wallWidth, screenWidth, wallWidth)
    bottomWall.type = "Floor"

    if allWalls then
        local rightWall = Wall(screenWidth - wallWidth, 0, wallWidth, screenHeight)
        local leftWall = Wall(0, 0, wallWidth, screenHeight)
        local topWall = Wall(0, 0, screenWidth, wallWidth)
        topWall.type = "Ceiling"
    end

end

function level(player)
    local currentLevel = {}
    local num = math.floor(math.random() * 10)
    local level, x, y

    if num < 3 then
        level = 1
    elseif num > 2 and num < 6 then
        level = 2
    elseif num > 5 then
        level = 3
    end

    level = 2

    if level == 1 then
        bg()
        walls(true)
        local b1 = BigBlock(27, 177)
        local b3 = SmallBlock(207, 167)
        local b32 = Block(287, 127, 25, 65)
        local b4 = Block(347, 99, 25, 93)
        local b6 = Block(207, 47, 105, 25)
        local b7 = Block(127, 87, 25, 105)
        local b8 = Block(-5, 47, 67, 25)
        local b9 = Block(-5, 127, 27, 25)
        x = 53
        y = 160
    end

    if level == 2 then

        walls()
        currentLevel.player = player
        local num = 0

        function spawnBlock()
            local blockName = 'block' .. num
            num += 1
            currentLevel[blockName] = Block(500, 200, 50, 100)
        end
        
    end

    if level == 3 then
        walls()
        x = 200
        y = 200
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