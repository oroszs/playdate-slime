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
local current, player, spawner, spawned, score
local slimeAnim = gfx.imagetable.new("images/slime-anim")


math.randomseed(pd.getSecondsSinceEpoch())

function restart()
    if pd.buttonIsPressed("down") and pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        initialize()
    end
end

function initialize()
    score = 1
    player = Player(slimeAnim, 100, 100, 15)
    current = level(player)
    local blockTime = 5000
    spawner = gfx.animator.new(blockTime, 0, 100)
    spawner.repeatCount = -1

    spawnBlock()

end

initialize()

function playdate.update()
    restart()
    gfx.sprite.update()
    scroll(current)
    if spawner:currentValue() < 10 then spawned = false end
    if spawner:currentValue() > 90 and not spawned then
        spawned = true
        score = spawnBlock()
    end
    gfx.drawText(score, 375, 25)
end