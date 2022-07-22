import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "libraries/AnimatedSprite"
import "obstacles"
import "player"

local pd <const> = playdate
local gfx <const> = pd.graphics
local player = nil
local slimeTable = gfx.imagetable.new("images/slime")

math.randomseed(pd.getSecondsSinceEpoch())

function spawnPlayer()
    player = Player(slimeTable, 0, 0, 15)
end

function restart()
    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        initialize()
    end
end

function walls()
    ---screen dimensions: 400 x 240
    local wallWidth = 5
    local screenWidth = 400
    local screenHeight = 240
    local rightWall = Wall(screenWidth - wallWidth, 0, wallWidth, screenHeight)
    local leftWall = Wall(0, 0, wallWidth, screenHeight)
    local bottomWall = Wall(0, screenHeight - wallWidth, screenWidth, wallWidth)
    bottomWall.type = "Floor"
    local topWall = Wall(0, 0, screenWidth, wallWidth)
    topWall.type = "Ceiling"
end

function level()

    local num = math.floor(math.random() * 10)
    local level

    if num < 5 then
        level = 1
    else
        level = 2
    end

    if level == 1 then
        local b1 = BigBlock(27, 177)
        local b3 = SmallBlock(207, 167)
        local b32 = Block(287, 127, 25, 65)
        local b4 = Block(347, 99, 25, 93)
        local b6 = Block(207, 47, 105, 25)
        local b7 = Block(127, 87, 25, 105)
        local b8 = Block(-5, 47, 67, 25)
        local b9 = Block(-5, 127, 27, 25)
        player:moveTo(53, 160)
    end

    if level == 2 then
        player:moveTo(20, 100)
    end

    if level == 3 then
        player:moveTo(20, 200)
    end

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

function initialize()
    spawnPlayer()
    bg()
    walls()
    level()
end

initialize()

function playdate.update()
    restart()
    gfx.sprite.update()
end