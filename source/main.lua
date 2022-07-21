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
local maxFallSpeed = 15
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
        self.canJump = false
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
    slimeSprite.collisionResponse = "slide"

end

function physicsUpdate()

    local newTime = pd.getCurrentTimeMilliseconds()
    dt = (newTime - lastTime) / 100
    lastTime = newTime
    local gForce = grav * dt

    local collSprites = slimeSprite.querySpritesInRect(slimeSprite.x + 1, slimeSprite.y + slimeSprite.w, slimeSprite.w - 2, 2)
    local wasGrounded = slimeSprite.grounded
    slimeSprite.grounded = false
    for i = 1, #collSprites do
        if not (collSprites[i] == slimeSprite) then
            slimeSprite.grounded = true
        end
    end

    local jumpSprites = slimeSprite.querySpritesInRect(slimeSprite.x + 1, slimeSprite.y + slimeSprite.w, slimeSprite.w - 2, 10)
    slimeSprite.canJump = false
    for i = 1, #jumpSprites do
        if not (jumpSprites[i] == slimeSprite) then
            slimeSprite.canJump = true
        end
    end
    if not (wasGrounded == slimeSprite.grounded) then
        --if slimeSprite.grounded then print('Grounded') else print('Not Grounded') end
    end

    local ceilSprites = slimeSprite.querySpritesInRect(slimeSprite.x, slimeSprite.y, slimeSprite.w, 4)

    for i = 1, #ceilSprites do
        if not (ceilSprites[i] == slimeSprite) then
            slimeSprite.dy = 0
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

            spr:moveWithCollisions(math.floor(spr.x + spr.dx), math.ceil(spr.y + spr.dy))

        end
    end

    gfx.sprite.performOnAllSprites(gravity)


end

function moveSprite()
    local pSpeed = playerSpeed * dt
    slimeSprite.dx = 0

    if (pd.buttonJustPressed("up") or pd.buttonJustPressed("a") or pd.buttonJustPressed("b")) and (slimeSprite.grounded or slimeSprite.canJump) then
        if not slimeSprite.grounded then print('Ghost Jump!') end
        slimeSprite.dy = -jumpForce
        slimeSprite:moveWithCollisions(math.floor(slimeSprite.x), math.ceil(slimeSprite.y + slimeSprite.dy))
    end

    if (pd.buttonJustReleased("up") or pd.buttonJustReleased("a") or pd.buttonJustReleased("b")) and slimeSprite.dy < 0 then
        slimeSprite.dy /= 2
    end

    if pd.buttonIsPressed("left") then
        slimeSprite.dx = -pSpeed
    end

    if pd.buttonIsPressed("right") then
        slimeSprite.dx = pSpeed
    end

end

function restart()

    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
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
        self:setCenter(0,0)
        self:setCollideRect(0, 0, self:getSize())
        self:moveTo(x, y)
        self:add()
        self.type = "Wall"
    end

    class('Block').extends('Wall')

    function Block:init(x, y, w, h)
        Block.super.init(self, x, y, w, h)
        self.type = "Block"
        function self:draw()
            local r = 4
            gfx.fillRoundRect(0, 0, w, h, r)
        end
    end

    class('SmallBlock').extends('Block')

    function SmallBlock:init(x, y)
        SmallBlock.super.init(self, x, y, 25, 25)
    end

    class('BigBlock').extends('Block')

    function BigBlock:init(x, y)
        BigBlock.super.init(self, x, y, 75, 75)
    end

    local rightWall = Wall(screenWidth - wallWidth, 0, wallWidth, screenHeight)
    local leftWall = Wall(0, 0, wallWidth, screenHeight)
    local bottomWall = Wall(0, screenHeight - wallWidth, screenWidth, wallWidth)
    bottomWall.type = "Floor"
    local topWall = Wall(0, 0, screenWidth, wallWidth)
    topWall.type = "Ceiling"

    local num = math.floor(math.random() * 10)

    local level

    if num < 5 then
        level = 1
    else
        level = 2
    end

    level = 1

    if level == 1 then
        
        local b1 = BigBlock(27, 177)
        local b3 = SmallBlock(207, 167)
        local b32 = Block(287, 127, 25, 65)
        local b4 = Block(347, 99, 25, 93)
        local b6 = Block(207, 47, 105, 25)
        local b7 = Block(127, 87, 25, 105)
        local b8 = Block(-5, 47, 67, 25)
        local b9 = Block(-5, 127, 27, 25)


        slimeSprite:moveTo(53, 160)

    end

    if level == 2 then
    

        slimeSprite:moveTo(x, y)

    end

    if level == 3 then

        slimeSprite:moveTo(20, 200)
    end

end

function setup()

    spriteSetup()
    bgSetup()

end

setup()


function playdate.update()

    restart()
    physicsUpdate()
    moveSprite()
    gfx.sprite.update()

end