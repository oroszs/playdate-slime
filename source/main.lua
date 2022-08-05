import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/ui"
import "libraries/AnimatedSprite"
import "obstacles"
import "player"
import "level"

local pd <const> = playdate
local gfx <const> = pd.graphics
local current, player, score, crankUI, spawnTimer, spawning
local slimeAnim = gfx.imagetable.new("images/slime-anim")


math.randomseed(pd.getSecondsSinceEpoch())

function pause()
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextInRect('*Paused*', 165, 120, 75, 50)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function restart()
    if pd.buttonJustPressed("a") or pd.buttonJustPressed("b") then
        gfx.sprite.removeAll()
        spawnTimer:remove()
        initialize()
    end
end

function initialize()

    player = Player(slimeAnim, 100, 100, 15)
    current = level(player)

    spawnTimer = pd.timer.keyRepeatTimerWithDelay(5000, 5000, spawnBlock)

    if pd.isCrankDocked() then
        crankUI = true
        pause()
        pd.ui.crankIndicator:start()
        spawnTimer:pause()
        spawning = false
    else
        crankUI = false
        spawning = true
    end

end

initialize()

function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
    if player.alive then
        if not pd.isCrankDocked() then
            if crankUI then
                crankUI = false
            end
            if not spawning then
                spawning = true
                spawnTimer:start()
            end
            scroll(current)
            gfx.drawText(player.score, 375, 12)
        else
            if not crankUI then
                pd.ui.crankIndicator:start()
                crankUI = true
            end
            if spawning then
                spawning = false
                spawnTimer:pause()
            end
            pause()
            pd.ui.crankIndicator:update()
        end
    else
        if spawning then
            spawning = false
            spawnTimer:pause()
        end
        gfx.drawText('Game Over', 161, 50)
        gfx.drawText(player.score, 197, 25)
        gfx.drawText('Press A or B to Restart', 110, 75)
        restart()
    end
end