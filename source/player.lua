import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"


local pd = playdate
local gfx = pd.graphics
local lt = pd.getCurrentTimeMilliseconds()
local collSize = 2

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
end

class('Player').extends(AnimatedSprite)

function Player:init(imageTable, x, y, w)

    Player.super.init(self, imageTable)

    self.aim = Aim(x, y, 30)
    self.aim:add()
    self.alive = true
    self.aimVec = pd.geometry.vector2D.new(0, 0)
    self.acceleration = 1
    self.airSpeed = 4
    self.grav = 2
    self.fallSpeed = 8
    self.jumpForce = 6
    self.bounceForce = pd.geometry.vector2D.new(3, 5)
    self.w = w
    self.grounded = false
    self.canJump = false
    self.moveSpeed = 0
    self.dx = 0
    self.dy = 0
    self.collisionResponse = "slide"
    self.score = 0
    self.jumping = false
    self.hit = false
    self.name = 'Player'
    self:addState("Idle", 1, 7, {tickStep = 2}, true)
    self:addState("Jump", 26, 32, {tickStep = 2, nextAnimation = "Idle"})
    self:addState("Charge", 8, 25, {tickStep = 2, loop = false})
    self:setCollideRect(0, 1, self.w, self.w)
    self:setTag(3)
    self:setCenter(0,0)
    self:moveTo(x, y)

    self.states["Charge"].onAnimationEndEvent = function ()
		jump(self)
	end

    aim(self)
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
    spr:changeState("Jump")
    spr.dx = spr.aimVec.x * (jForce / 1.5)
    spr.dy = spr.aimVec.y * jForce
    
    spr:moveTo(spr.x + spr.dx, spr.y + spr.dy)
    spr.jumping = true
end

function getPos(ax, ay, r)
    local pArc = pd.geometry.arc.new(ax, ay, r, 0, 359.9)
    local len = pArc:length()
    local cp = pd.getCrankPosition()
    if cp > 70 and cp <= 110 then cp = 70
    elseif cp > 110 and cp <= 180 then cp = 180 - cp
    elseif cp > 180 and cp <= 250 then cp = 360 - (cp - 180)
    elseif cp > 250 and cp <= 290 then cp = 290
    end
    local amt = cp / 360
    local dist = amt * len
    local pos = pArc:pointOnArc(dist)
    return pos
end

function Player:update()

    Player.super.update(self)
    local dt = deltaTime(lt)
    if self.alive and not pd.isCrankDocked() then
        aliveCheck(self)
        groundCheck(self)
        jumpCheck(self, 10)
        ceilCheck(self, 4)
        gravity(self, dt)
        move(self, dt)
        if self.grounded then aim(self) else self.aim:moveTo(-10, -10) end
    end
    if not self.alive then
        self.aim:remove()
    end

end

function aliveCheck(spr)
    if spr.x < -30 or spr.y > 260 then
        spr.alive = false
        spr:remove()
    end
end

function aim(spr)
    local pos = getPos(spr.x, spr.y, spr.aim.r)
    local vec = pd.geometry.vector2D.new(pos.x - spr.x, pos.y - spr.y)
    spr.aimVec = vec:normalized()
    spr.aim:moveTo(pos.x + 5, pos.y + 10)
end

function groundCheck(spr)
    local collSprites = spr.querySpritesInRect(spr.x, spr.y + spr.w, spr.w, 2)
    local wasGrounded = spr.grounded
    spr.grounded = false
    for i = 1, #collSprites do
        if not (collSprites[i] == spr) then
            spr.grounded = true
            spr.dx = 0
            if not (collSprites[i].type == 'MovingBlock') then
                spr.y = collSprites[i].y - spr.w
            end
            if (collSprites[i].type == 'Block') or (collSprites[i].type == 'MovingBlock') then
                if (collSprites[i].y - spr.w + 1) > spr.y then
                    if collSprites[i].cleared == false then
                        collSprites[i].cleared = true
                        spr.score += 1
                    end
                end
            end
        end
    end

    if not (wasGrounded == spr.grounded) then
        if spr.grounded then print('Grounded') else print('Not Grounded') end
    end
end

function jumpCheck(spr, collSize)
    local jumpSprites = spr.querySpritesInRect(spr.x, spr.y + spr.w, spr.w, collSize)
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

end

function bounceCheck(player, other)
    local hit = false
    if player.y > (other.y - player.w) then
        if player.x < other.x then
            player.dx = -player.bounceForce.x
            player.dy = -player.bounceForce.y
            print('before', player.x, player.y)
            player:moveTo(player.x + player.dx, player.y + player.dy)
            print('after', player.x, player.y)
            hit = true
            print('hit!')
        elseif player.x > other.x then
            player.dx = player.bounceForce.x
            player.dy = -player.bounceForce.y
            player:moveTo(player.x + player.dx, player.y + player.dy)
            hit = true
        end
    end
    return hit
end

function move(spr, dt)
    local aSpeed = spr.airSpeed * dt
    local accel = spr.acceleration * dt
    if spr.grounded then spr.moveSpeed = 0 end
    
    if pd.buttonJustPressed("up") and spr.canJump then
        spr:changeState("Charge")
    end

    if pd.buttonJustReleased("up") and spr.currentState == 'Charge' then
        jump(spr)
    end

    if pd.buttonIsPressed("left") then
        spr.moving = true
        if not spr.grounded then
            spr.moveSpeed -= accel
            if spr.moveSpeed < -aSpeed then spr.moveSpeed = -aSpeed end
        end
    end

    if pd.buttonIsPressed("right") then
        spr.moving = true
        if not spr.grounded then
            spr.moveSpeed += accel
            if spr.moveSpeed > aSpeed then spr.moveSpeed = aSpeed end
        end
    end

    if spr.currentState == "Charge" then spr.moveSpeed = 0 end

    if not spr.jumping then
        local overlaps
        local collSize = 8
        if spr.dx > 0 then
            overlaps = spr.querySpritesInRect(spr.x + spr.w, spr.y, collSize, spr.w)
        elseif spr.dx <= 0 then
            overlaps = spr.querySpritesInRect(spr.x - collSize, spr.y, collSize, spr.w)
        end
        if not spr.hit then
            for j = 1, #overlaps do
                if overlaps[j]:getTag() == 2 and not spr.hit then
                    spr.hit = bounceCheck(spr, overlaps[j])
                end
            end
        end
        if not spr.hit then
            local ax, ay, colls, len = spr:moveWithCollisions(spr.x + spr.dx + spr.moveSpeed, spr.y + spr.dy)
            for i = 1, #colls do
                if colls[i].other:getTag() == 4 then
                    spr.alive = false
                    spr:remove()
                elseif colls[i].other:getTag() == 2 then
                    bounceCheck(spr, colls[i].other)
                end
            end
        end
        spr.hit = false
    end
    spr.jumping = false

end