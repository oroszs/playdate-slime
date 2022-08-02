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
    if player.alive then
        scroll(current)
        gfx.drawText(player.score, 375, 25)
    else
        gfx.drawText('Game Over', 155, 50)
        gfx.drawText(player.score, 200, 25)
        gfx.drawText('Hold Down and Press B to Restart', 75, 75)
    end
    if spawner:currentValue() < 10 then spawned = false end
    if spawner:currentValue() > 90 and not spawned then
        spawned = true
        spawnBlock()
    end
end