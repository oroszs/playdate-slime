import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/ui"
import 'CoreLibs/keyboard'
import "libraries/AnimatedSprite"
import "player"
import "obstacles"
import "level"

local pd <const> = playdate
local gfx <const> = pd.graphics
local current, player, score, crankUI, spawnTimer, spawning
local slimeAnim = gfx.imagetable.new("images/slime-anim")
local gameState = 'Menu'
local newHighScore = false

local leader = pd.datastore.read('leaderboard')
local tempLeader = {}
if not leader then
    for i = 1, 5 do
        tempLeader[i] = ('Player-'..0)
    end
    pd.datastore.write(tempLeader, 'leaderboard', true)
    leader = tempLeader
end

local highIndex = string.find(leader[1], '-')
local highestScore = string.sub(leader[1], highIndex + 1)
highestScore = tonumber(highestScore)

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
        newHighScore = false
        clearSprites()
        startGame()
    elseif pd.buttonJustPressed('b') then
        newHighScore = false
        gameState = 'Menu'
        clearSprites()
    end
end

function mainMenu()
    if pd.buttonJustPressed('a') then
        gfx.clear()
        startGame()
    elseif pd.buttonJustPressed('b') then
        gameState = 'Leaderboard'
        gfx.clear()
    end
end

function leaderboard()
    if pd.buttonJustPressed('b') then
        gameState = 'Menu'
        gfx.clear()
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
        gfx.drawTextAligned('B - Leaderboard', 200, 145, kTextAlignment.center)
        mainMenu()
    elseif gameState == 'Leaderboard' then
        local scoreFont = gfx.font.new('fonts/Roobert/Roobert-10-Bold')
        local titleFont = gfx.font.new('fonts/Roobert/Roobert-24-Medium')
        local subTitleFont = gfx.font.new('fonts/Roobert/Roobert-11-Medium')
        titleFont:drawTextAligned('High Scores', 200, 10, kTextAlignment.center)
        for i = 1, #leader do
            local index = string.find(leader[i], '-')
            local name = string.sub(leader[i], 1, index - 1)
            local score = string.sub(leader[i], index + 1)
            local string = (i..'. '..name..' - '..score)
            scoreFont:drawTextAligned(string, 200, (50 + (i * 20)), kTextAlignment.center)
        end
        subTitleFont:drawTextAligned('B - Main Menu', 200, 200, kTextAlignment.center)
        leaderboard()
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
                local scoreString = player.score
                if player.score > highestScore then
                    scoreString = (player.score..' !')
                end
                gfx.drawTextAligned(scoreString, 200, 25, kTextAlignment.center)
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

            for i = 1, #leader do
                local index = string.find(leader[i], '-')
                local score = string.sub(leader[i], index + 1)
                score = tonumber(score)
                if player.score > score then
                    newHighScore = true
                    leader[i] = player.name..'-'..player.score
                    pd.datastore.write(leader, 'leaderboard', true)
                end
                if newHighScore then break end
            end
            gfx.setImageDrawMode('fillWhite')
            gfx.fillRoundRect(100, 15, 200, 125, 5)
            if newHighScore then
                gfx.drawTextAligned('High Score!', 200, 50, kTextAlignment.center)
            else
                gfx.drawTextAligned('Game Over', 200, 50, kTextAlignment.center)
            end
            gfx.drawTextAligned(player.score, 200, 25, kTextAlignment.center)
            gfx.drawTextAligned('A - Restart', 200, 95, kTextAlignment.center)
            gfx.drawTextAligned('B - Main Menu', 200, 115, kTextAlignment.center)
            gfx.setImageDrawMode('fillBlack')
            restart()
        end
    end
end