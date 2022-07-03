import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "libraries/AnimatedSprite.lua"

local pd <const> = playdate
local gfx <const> = pd.graphics

local slimeSprite = nil
local playerSpeed = 3

function spriteSetup()

    local slimeTable = gfx.imagetable.new("images/slime")
    slimeSprite = AnimatedSprite.new(slimeTable)
    slimeSprite:addState("Idle", 1, 6, {tickStep = 2})
    slimeSprite:playAnimation()
    slimeSprite:moveTo(200, 120)
    slimeSprite:setCollideRect(0, 1, 16, 15)

end

function moveSprite()

    if pd.buttonIsPressed("up") then
        slimeSprite:moveWithCollisions(slimeSprite.x, slimeSprite.y - playerSpeed)
    end
    if pd.buttonIsPressed("down") then
        slimeSprite:moveWithCollisions(slimeSprite.x, slimeSprite.y + playerSpeed)
    end
    if pd.buttonIsPressed("left") then
        slimeSprite:moveWithCollisions(slimeSprite.x - playerSpeed, slimeSprite.y)
    end
    if pd.buttonIsPressed("right") then
        slimeSprite:moveWithCollisions(slimeSprite.x + playerSpeed, slimeSprite.y)
    end

end

function bgSetup()
    
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

    ---screen dimensions: 400 x 240

    local wallWidth = 5
    local screenWidth = 400
    local screenHeight = 240

    class('Wall').extends(gfx.sprite)

    function Wall:init(x, y, w, h)
        Wall.super.init(self)
        function self:draw()
            gfx.fillRect(0, 0, w, h)
        end
        self:setSize(w, h)
        self:setCollideRect(0, 0, self:getSize())
        self:moveTo(x, y)
        self:add()
    end

    local rightWall = Wall(screenWidth, 120, wallWidth, screenHeight)
    local leftWall = Wall(0, 120, wallWidth, screenHeight)
    local bottomWall = Wall(200, screenHeight, screenWidth, wallWidth)
    local topWall = Wall(200, 0, screenWidth, wallWidth)

end

function setup()

    spriteSetup()
    bgSetup()

end

setup()


function playdate.update()

    moveSprite()
    gfx.sprite.update()

end