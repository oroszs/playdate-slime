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
    function self:draw()
        local r = 4
        gfx.fillRoundRect(0, 0, w, h, r)
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