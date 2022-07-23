import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "libraries/AnimatedSprite"
import "obstacles"
import "player"
import "level"

local pd <const> = playdate
local gfx <const> = pd.graphics
local player = nil
local slimeTable = gfx.imagetable.new("images/slime")
local spawnX, spawnY, current

math.randomseed(pd.getSecondsSinceEpoch())

function spawnPlayer(x, y)
    player = Player(slimeTable, x, y, 15)
end

function restart()
    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        initialize()
    end
end

function initialize()
    spawnX, spawnY, current = level()
    spawnPlayer(spawnX, spawnY)
end

initialize()

function playdate.update()
    restart()
    gfx.sprite.update()
    scroll(current)
end