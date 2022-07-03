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
    slimeSprite:moveTo(21, 219)
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

    class('Block').extends('Wall')

    function Block:init(x, y, w, h)
        Block.super.init(self, x, y, w, h)
        self:setCollideRect(0, 0, w, h - 1)
    end

    local rightWall = Wall(screenWidth, 120, wallWidth, screenHeight)
    local leftWall = Wall(0, 120, wallWidth, screenHeight)
    local bottomWall = Wall(200, screenHeight, screenWidth, wallWidth)
    local topWall = Wall(200, 0, screenWidth, wallWidth)

    local level = 1

    if level == 1 then
        
        local leftBottomWall = Wall(50, (screenHeight / 2) + 38, wallWidth, 158)
        local leftTopWall = Wall(100, 82, wallWidth, 158)

        local obs1 = Block(175, 50, 20, 20)
        local obs2 = Block(175, 120, 20, 20)
        local obs3 = Block(175, 190, 20, 20)
        local obs4 = Block(300, 120, 100, 100)



    end

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