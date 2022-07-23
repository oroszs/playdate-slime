import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

class('Player').extends(AnimatedSprite)

local pd = playdate
local gfx = pd.graphics
local lt = pd.getCurrentTimeMilliseconds()

function Player:init(imageTable, x, y, w)

    Player.super.init(self, imageTable)

    self.speed = 10
    self.grav = 2
    self.fallSpeed = 15
    self.jumpForce = 10
    self.w = w
    self.grounded = false
    self.canJump = false
    self.dx = 0
    self.dy = 0
    self.collisionResponse = "slide"
    self:addState("Idle", 1, 6, {tickStep = 2})
    self:playAnimation()
    self:setCollideRect(0, 1, self.w, self.w)
    self:setTag(1)
    self:setCenter(0,0)
    self:moveTo(x, y)

end

function Player:update()

    Player.super.update(self)

    local dt = deltaTime(lt)
    groundCheck(self)
    jumpCheck(self, 10)
    ceilCheck(self, 4)
    gravity(self, dt)
    move(self, dt)

end

function groundCheck(spr)
    local collSprites = spr.querySpritesInRect(spr.x + 1, spr.y + spr.w, spr.w - 2, 2)
    local wasGrounded = spr.grounded
    spr.grounded = false
    for i = 1, #collSprites do
        if not (collSprites[i] == spr) then
            spr.grounded = true
        end
    end

    if not (wasGrounded == spr.grounded) then
        --if slimeSprite.grounded then print('Grounded') else print('Not Grounded') end
    end

end

function jumpCheck(spr, collSize)
    local jumpSprites = spr.querySpritesInRect(spr.x + 1, spr.y + spr.w, spr.w - 2, collSize)
    spr.canJump = false
    for i = 1, #jumpSprites do
        if not (jumpSprites[i] == spr) then
            spr.canJump = true
        end
    end
end

function ceilCheck(spr, collSize)
    local ceilSprites = spr.querySpritesInRect(spr.x, spr.y, spr.w, collSize)
    
    for i = 1, #ceilSprites do
        if not (ceilSprites[i] == spr) then
            spr.dy = 0
        end
    end
end

function deltaTime(lastTime)
    local newTime = pd.getCurrentTimeMilliseconds()
    local dt = (newTime - lastTime) / 100
    lt = newTime
    return dt
end

function gravity(spr, dt)

    local gForce = spr.grav * dt

    if not spr.grounded then
        if spr.dy < spr.fallSpeed then
            spr.dy += gForce else
            spr.dy = spr.fallSpeed
        end
    else
        spr.dy = 0
    end

    spr:moveWithCollisions(math.floor(spr.x + spr.dx), math.ceil(spr.y + spr.dy))

end

function move(spr, dt)
    local pSpeed = spr.speed * dt
    spr.dx = 0

    if (pd.buttonJustPressed("up") or pd.buttonJustPressed("a") or pd.buttonJustPressed("b")) and (spr.grounded or spr.canJump) then
        if not spr.grounded then print('Ghost Jump!') end
        spr.dy = -spr.jumpForce
        spr:moveWithCollisions(math.floor(spr.x), math.ceil(spr.y + spr.dy))
    end

    if (pd.buttonJustReleased("up") or pd.buttonJustReleased("a") or pd.buttonJustReleased("b")) and spr.dy < 0 then
        spr.dy /= 2
    end

    if pd.buttonIsPressed("left") then
        spr.dx = -pSpeed
    end

    if pd.buttonIsPressed("right") then
        spr.dx = pSpeed
    end

end