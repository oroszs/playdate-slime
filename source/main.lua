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
local current, player, spawner
local slimeAnim = gfx.imagetable.new("images/slime-anim")


math.randomseed(pd.getSecondsSinceEpoch())

function restart()
    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        initialize()
    end
end

function initialize()
    player = Player(slimeAnim, 100, 100, 15)
    current = level(player)
    local blockTime = 1000
    spawner = gfx.animator.new(5000, 0, 100)
    spawner.repeatCount = -1

end

initialize()

function playdate.update()
    restart()
    gfx.sprite.update()
    scroll(current)
    if spawner:currentValue() > 90 then
        spawnBlock()
    end
end