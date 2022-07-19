import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "libraries/AnimatedSprite.lua"

local pd <const> = playdate
local gfx <const> = pd.graphics

local slimeSprite, dt = nil
local playerSpeed = 10
local grav = 2
local lastTime = pd.getCurrentTimeMilliseconds()
local maxFallSpeed = 10
local jumpForce = 10

math.randomseed(pd.getSecondsSinceEpoch())

function spriteSetup()
--[[
    class('Debug').extends(gfx.sprite)

    function Debug:init(x, y, w, h)
        Debug.super.init(self)
        function self:draw()
            gfx.drawRect(0, 0, w, h)
        end
        self:moveTo(x, y + w)
        self:setSize(w, h)
        self:setCenter(0,0)
        self:add()
    end
]]
    class('Slime').extends(AnimatedSprite)

    function Slime:init(imageTable, x, y, w)
        Slime.super.init(self, imageTable)
        --self.debug = Debug(x, y, w, 2)
        self.w = w
        self.grounded = false
        self.dx = 0
        self.dy = 0
    end

    local slimeTable = gfx.imagetable.new("images/slime")
    slimeSprite = Slime(slimeTable, 0, 0, 15)
    slimeSprite:addState("Idle", 1, 6, {tickStep = 2})
    slimeSprite:playAnimation()
    slimeSprite:setCollideRect(0, 1, slimeSprite.w, slimeSprite.w)
    slimeSprite:setTag(1)
    slimeSprite:setCenter(0,0)

    function Slime:moveTo(x, y)
        Slime.super.moveTo(self, x, y)
        --self.debug:moveTo(x, y + self.w)
    end
    function Slime:moveWithCollisions(x, y)
        local wasGrounded = self.grounded
        Slime.super.moveWithCollisions(self, x, y)
        if not (wasGrounded == self.grounded) then
            if self.grounded then print('Grounded') else print('Not Grounded') end
        end
        --self.debug:moveTo(x, y + self.w)
    end

end

function physicsUpdate()

    local newTime = pd.getCurrentTimeMilliseconds()
    dt = (newTime - lastTime) / 100
    lastTime = newTime
    local gForce = grav * dt

    local collSprites = slimeSprite.querySpritesInRect(slimeSprite.x, slimeSprite.y + slimeSprite.w, slimeSprite.w, 2)
    slimeSprite.grounded = false
    for i = 1, #collSprites do
        if not (collSprites[i] == slimeSprite) then
            slimeSprite.grounded = true
        end
    end

    gravity = function (spr)
        if spr:getTag() == 1 then
            if not spr.grounded then
                if spr.dy < maxFallSpeed then
                    spr.dy += gForce else
                    spr.dy = maxFallSpeed
                end
            else
                spr.dy = 0
            end

            spr:moveWithCollisions(spr.x, spr.y + spr.dy)
        end
    end

    gfx.sprite.performOnAllSprites(gravity)


end

function moveSprite()
    local pSpeed = playerSpeed * dt

    if pd.buttonJustPressed("up") and slimeSprite.grounded then
        slimeSprite.dy = -jumpForce
        coll = slimeSprite:moveWithCollisions(slimeSprite.x, slimeSprite.y + slimeSprite.dy)
    end
    if pd.buttonIsPressed("left") then
        coll = slimeSprite:moveWithCollisions(slimeSprite.x - pSpeed, slimeSprite.y + slimeSprite.dy)
    end
    if pd.buttonIsPressed("right") then
        coll = slimeSprite:moveWithCollisions(slimeSprite.x + pSpeed, slimeSprite.y + slimeSprite.dy)
    end

end

function restart()

    if pd.buttonJustPressed("a") then
        gfx.sprite.removeAll()
        spriteSetup()
        bgSetup()
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
        self.type = "Wall"
    end

    class('Block').extends('Wall')

    function Block:init(x, y, w, h)
        Block.super.init(self, x, y, w, h)
        self:setCollideRect(0, 0, w, h - 1)
        self.type = "Block"
        function self:draw()
            local r = w / 7
            gfx.fillRoundRect(0, 0, w, h, r)
        end
    end

    local rightWall = Wall(screenWidth, 120, wallWidth, screenHeight)
    local leftWall = Wall(0, 120, wallWidth, screenHeight)
    local bottomWall = Wall(200, screenHeight, screenWidth, wallWidth)
    bottomWall.type = "Floor"
    local topWall = Wall(200, 0, screenWidth, wallWidth)
    topWall.type = "Ceiling"

    local num = math.floor(math.random() * 10)

    local level

    if num < 5 then
        level = 1
    else
        level = 2
    end


    if level == 1 then
        
        local leftBottomWall = Wall(50, (screenHeight / 2) + 38, wallWidth, 158)
        local leftTopWall = Wall(100, 82, wallWidth, 158)

        local obs1 = Block(175, 50, 20, 20)
        local obs2 = Block(175, 120, 20, 20)
        local obs3 = Block(175, 190, 20, 20)
        local obs4 = Block(300, 120, 100, 100)

        slimeSprite:moveTo(21, 219)

    end

    if level == 2 then
    
        local obs1 = Block(200, 40, 25, 25)
        local obs2 = Block(200, 120, 100, 100)
        local obs3 = Block(200, 200, 25, 25)

        slimeSprite:moveTo(21, 119)

    end

    if level == 3 then
        slimeSprite:moveTo(200, 120)
    end

end

function setup()

    spriteSetup()
    bgSetup()

end

setup()


function playdate.update()

    physicsUpdate()
    moveSprite()
    gfx.sprite.update()
    restart()

end