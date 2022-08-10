import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/easing"

local gfx = playdate.graphics

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
    self.cleared = false
    function self:draw()
        local r = 4
        if not self.cleared then
            gfx.drawRoundRect(0, 0, w, h, r)
        else
            gfx.fillRoundRect(0, 0, w, h, r)
        end
    end
    self:setTag(2)
end

class('MovingBlock').extends('Block')

function MovingBlock:init(x, y, w, h, t, d)
    MovingBlock.super.init(self, x, y, w, h)
    self.type = 'MovingBlock'
    self.on = false
    self.w = w
    self.player = nil
    local top = y - d
    local bottom = y + d
    if top < 75 then top = 75 end
    if bottom > 225 then bottom = 225 end
    local dir = math.floor(math.random() * 2)
    if dir == 0 then
        self.startVal = top
        self.endVal = bottom
        self.dir = 1
    else
        self.startVal = bottom
        self.endVal = top
        self.dir = -1
    end
    self.moveAnim = gfx.animator.new(t, self.startVal, self.endVal, playdate.easingFunctions.inOutCubic)
    self.moveAnim.repeatCount = -1
    self.moveAnim.reverses = true
    self:moveTo(x, self.startVal)
end

function MovingBlock:update()
    MovingBlock.super.update(self)
    if self.moveAnim:currentValue() == self.startVal or self.moveAnim:currentValue() == self.endVal then
        self.dir *= -1
    end
    self.on = false
    local cur = self.moveAnim:currentValue()
    local sprites = self.querySpritesInRect(self.x, self.y - 2, self.w, 2)
    for i = 1, #sprites do
        if sprites[i]:getTag() == 3 then
            self.on = true
            self.player = sprites[i]
        end
    end
    if self.on then
        if self.dir == -1 then
            self.player:moveTo(self.player.x, cur - self.player.w)
            self:moveTo(self.x, cur)
        else
            self:moveTo(self.x, cur)
            self.player:moveTo(self.player.x, cur - self.player.w)
        end
    else
        self:moveTo(self.x, cur)
    end
end

class('SpikeWall').extends(gfx.sprite)

function SpikeWall:init(x, y)
    self.type = 'SpikeWall'
    self.cleared = false
    self.top = Block(x, -10, 25, y - 100)
    self.bottom = Block(x, y - 50, 25, 250 - y + 50)
    self.top:setTag(4)
    self.bottom:setTag(4)
    SpikeWall.super.init(self)
    self:setSize(25, 260)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()
    self:setTag(2)
end

function SpikeWall:update()
    local spr = self
    self.top:moveTo(spr.x, -10)
    self.bottom:moveTo(spr.x, spr.y - 50)
    if self.cleared then
        self.top.cleared = true
        self.bottom.cleared = true
    end
end