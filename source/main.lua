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
local current


math.randomseed(pd.getSecondsSinceEpoch())

function restart()
    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        initialize()
    end
end

function initialize()
    current = level()
end

initialize()

function playdate.update()
    restart()
    gfx.sprite.update()
    --scroll(current)
end