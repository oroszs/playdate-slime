import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/ui"
import "libraries/AnimatedSprite"
import "player"
import "obstacles"
import "level"

local pd <const> = playdate
local gfx <const> = pd.graphics
local current, player, score, crankUI, spawnTimer, spawning
local slimeAnim = gfx.imagetable.new("images/slime-anim")
local gameState = 'Menu'


math.randomseed(pd.getSecondsSinceEpoch())

function pause()
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned('*Paused*', 200, 120, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function clearSprites()
    gfx.sprite.removeAll()
    if spawnTimer then
        spawnTimer:remove()
    end
end

function restart()
    if pd.buttonJustPressed("a") then
        clearSprites()
        startGame()
    elseif pd.buttonJustPressed('b') then
        gameState = 'Menu'
        clearSprites()
        mainMenu()
    end
end

function mainMenu()
    if pd.buttonJustPressed('a') then
        gfx.clear()
        startGame()
    end
end

function startGame()
    gameState = 'Game'

    player = Player(slimeAnim, 100, 185, 15)
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


function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
    if gameState == 'Menu' then
        gfx.drawTextAligned('*Slime Climb*', 200, 25, kTextAlignment.center)
        gfx.drawTextAligned('A - Start', 200, 120, kTextAlignment.center)
        mainMenu()
    elseif gameState == 'Game' then
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
                gfx.drawTextAligned(player.score, 200, 25, kTextAlignment.center)
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
            gfx.setImageDrawMode('fillWhite')
            gfx.fillRoundRect(100, 15, 200, 125, 5)
            gfx.drawTextAligned('Game Over', 200, 50, kTextAlignment.center)
            gfx.drawTextAligned(player.score, 200, 25, kTextAlignment.center)
            gfx.drawTextAligned('A - Restart', 200, 95, kTextAlignment.center)
            gfx.drawTextAligned('B - Main Menu', 200, 115, kTextAlignment.center)
            gfx.setImageDrawMode('fillBlack')
            restart()
        end
    end
end