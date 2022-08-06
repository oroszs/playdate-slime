import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

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

class('SmallBlock').extends('Block')

function SmallBlock:init(x, y)
    SmallBlock.super.init(self, x, y, 25, 25)
end

class('BigBlock').extends('Block')

function BigBlock:init(x, y)
    BigBlock.super.init(self, x, y, 75, 75)
end

class('SpikeWall').extends(gfx.sprite)

function SpikeWall:init(x, y)
    self.type = 'spikeWall'
    self.cleared = false
    self.top = Block(x, -10, 25, y - 100)
    self.bottom = Block(x, y - 25, 25, 250 - y + 25)
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
    self.bottom:moveTo(spr.x, spr.y - 25)
    if self.cleared then
        self.top.cleared = true
        self.bottom.cleared = true
    end
end