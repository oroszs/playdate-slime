import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"


local pd = playdate
local gfx = pd.graphics
local lt = pd.getCurrentTimeMilliseconds()

class('Aim').extends(gfx.sprite)

function Aim:init(x, y, r)
    Aim.super.init(self)
    self.r = r
    local img = gfx.image.new(30, 30)
    gfx.pushContext(img)
        gfx.fillCircleInRect(0, 0, 5, 5)
    gfx.popContext()
    self:setImage(img)
    self:setCenter(0, 0)
    self:add()
end

class('Player').extends(AnimatedSprite)

function Player:init(imageTable, x, y, w)

    Player.super.init(self, imageTable)

    self.aim = Aim(x, y, 30)

    self.aimVec = pd.geometry.vector2D.new(0, 0)
    self.groundSpeed = 2
    self.airSpeed = 5
    self.grav = 2
    self.fallSpeed = 10
    self.jumpForce = 6
    self.w = w
    self.grounded = false
    self.canJump = false
    self.moveSpeed = 0
    self.dx = 0
    self.dy = 0
    self.collisionResponse = "slide"
    self:addState("Idle", 1, 7, {tickStep = 2}, true)
    self:addState("Jump", 26, 32, {tickStep = 2, nextAnimation = "Idle"})
    self:addState("Charge", 8, 25, {tickStep = 2, loop = false})
    self:setCollideRect(0, 1, self.w, self.w)
    self:setTag(1)
    self:setCenter(0,0)
    self:moveTo(x, y)

    self.states["Charge"].onAnimationEndEvent = function ()
		jump(self)
	end

end

function jump(spr)
    --[[
        8 | 24 : weak
        9 - 12 | 20 - 23 : medium
        13 - 14 | 18 - 19 : strong
        15 - 17 : max
    ]]
    local jForce
    local weak = 6
    local medium = 8
    local strong = 10
    local max = 12
    local chargeFrame = spr:getCurrentFrameIndex()
    if (chargeFrame > 7 and chargeFrame < 9) or (chargeFrame > 23) then jForce = weak
    elseif (chargeFrame > 8 and chargeFrame < 13) or (chargeFrame > 19 and chargeFrame < 24) then jForce = medium
    elseif (chargeFrame > 12 and chargeFrame < 15) or (chargeFrame > 17 and chargeFrame < 20) then jForce = strong
    elseif (chargeFrame > 14 and chargeFrame < 18) then jForce = max
    end
    print('frame: ', chargeFrame, 'force: ', jForce)
    spr:changeState("Jump")
    spr.dx = spr.aimVec.x * (jForce / 1.5)
    spr.dy = spr.aimVec.y * jForce

    if chargeFrame > 21 then spr:moveWithCollisions(spr.x + spr.dx, spr.y + spr.dy) end
end

function getPos(ax, ay, r)
    local pArc = pd.geometry.arc.new(ax, ay, r, 0, 359.9)
    local len = pArc:length()
    local cp = pd.getCrankPosition()
    local amt = cp / 360
    local dist = amt * len
    local pos = pArc:pointOnArc(dist)
    return pos
end

function Player:update()

    Player.super.update(self)
    local dt = deltaTime(lt)
    groundCheck(self)
    jumpCheck(self, 10)
    ceilCheck(self, 4)
    gravity(self, dt)
    move(self, dt)
    aim(self)

end

function aim(spr)
    local pos = getPos(spr.x, spr.y, spr.aim.r)
    local vec = pd.geometry.vector2D.new(pos.x - spr.x, pos.y - spr.y)
    spr.aimVec = vec:normalized()
    spr.aim:moveTo(pos.x + 5, pos.y + 10)
end

function groundCheck(spr)
    local collSprites = spr.querySpritesInRect(spr.x + 1, spr.y + spr.w, spr.w - 2, 2)
    local wasGrounded = spr.grounded
    spr.grounded = false
    for i = 1, #collSprites do
        if not (collSprites[i] == spr) then
            spr.grounded = true
            spr.dx = 0
            spr.y = collSprites[i].y - spr.w
        end
    end


    if not (wasGrounded == spr.grounded) then
        if spr.grounded then print('Grounded') else print('Not Grounded') end
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

    --spr:moveWithCollisions(spr.x + spr.dx, math.ceil(spr.y + spr.dy))

end

function move(spr, dt)
    local gSpeed = spr.groundSpeed * dt
    local aSpeed = spr.airSpeed * dt
    spr.moveSpeed = 0

    --[[
    if (pd.buttonJustPressed("up") or pd.buttonJustPressed("a") or pd.buttonJustPressed("b")) and (spr.grounded or spr.canJump) then
        if not spr.grounded then print('Ghost Jump!') end
        spr.dx = spr.aimVec.x * spr.jumpForce
        spr.dy = spr.aimVec.y * spr.jumpForce
        spr:moveWithCollisions(math.ceil(spr.x + spr.dx), math.ceil(spr.y + spr.dy))
    end

    if (pd.buttonJustReleased("up") or pd.buttonJustReleased("a") or pd.buttonJustReleased("b")) and spr.dy < 0 then
        spr.dy /= 2
    end
    ]]
    
    if pd.buttonJustPressed("up") and spr.canJump then
        spr:changeState("Charge")
    end

    if pd.buttonJustReleased("up") and spr.currentState == 'Charge' then
        jump(spr)
    end

    if pd.buttonIsPressed("left") then
        if spr.grounded then
            spr.moveSpeed = -gSpeed
        else
            spr.moveSpeed = -aSpeed
        end
    end

    if pd.buttonIsPressed("right") then
        if spr.grounded then
            spr.moveSpeed = gSpeed
        else
            spr.moveSpeed = aSpeed
        end
    end

    if spr.currentState == "Charge" then spr.moveSpeed = 0 end

    spr:moveWithCollisions(spr.x + spr.dx + spr.moveSpeed, spr.y + spr.dy)


end