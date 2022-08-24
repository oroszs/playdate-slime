import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import 'CoreLibs/keyboard'

local pd <const> = playdate
local gfx <const> = pd.graphics

local roobert_10 <const> = gfx.font.new('fonts/Roobert/Roobert-10-Bold')
local roobert_11 <const> = gfx.font.new('fonts/Roobert/Roobert-11-Medium')
local roobert_20 <const> = gfx.font.new('fonts/Roobert/Roobert-20-Medium')
local roobert_24 <const> = gfx.font.new('fonts/Roobert/Roobert-24-Medium')

local highIndex, highestScore
local newHighScore = false
local leader = pd.datastore.read('leaderboard')
local tempLeader = {}

local debug = false

if not leader or debug then
    for i = 1, 5 do
        tempLeader[i] = ('Player-'..0)
    end
    pd.datastore.write(tempLeader, 'leaderboard', true)
    leader = tempLeader
end




function pause()
    pd.ui.crankIndicator:update()
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    roobert_24:drawTextAligned('Paused', 200, 100, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function crankCheck(state)
    if pd.isCrankDocked() and not (state == 'Pause') then
        pd.ui.crankIndicator:start()
        spawnTimer:pause()
        spawning = false
        state = 'Pause'
    elseif not spawning then
        spawning = true 
        spawnTimer:start()
    end
    return state
end

function menu(state, player, leader)
    if state == 'Menu' then
        roobert_24:drawTextAligned('Slime Climb', 200, 25, kTextAlignment.center)
        roobert_11:drawTextAligned('A - Start', 200, 120, kTextAlignment.center)
        roobert_11:drawTextAligned('B - Leaderboard', 200, 145, kTextAlignment.center)

        if pd.buttonJustPressed('a') then
            startGame()
            state = 'Game'
            gfx.clear()
        elseif pd.buttonJustPressed('b') then
            state = 'Leaderboard'
            gfx.clear()
        end

        mainMenu()
    elseif state == 'Leaderboard' then
        roobert_24:drawTextAligned('High Scores', 200, 10, kTextAlignment.center)
        for i = 1, #leader do
            local index = string.find(leader[i], '-')
            local name = string.sub(leader[i], 1, index - 1)
            local score = string.sub(leader[i], index + 1)
            local string = (i..'. '..name..' - '..score)
            roobert_10:drawTextAligned(string, 200, (50 + (i * 20)), kTextAlignment.center)
        end
        roobert_11:drawTextAligned('B - Main Menu', 200, 200, kTextAlignment.center)
        if pd.buttonJustPressed('b') then
            state = 'Menu'
            gfx.clear()
        end    
    elseif gameState == 'Pause' then
        pause()
    elseif gameState == 'Game' then
        if player.alive then
            state = crankCheck('Game')
            local scoreString = player.score
            if player.score > highestScore then
                scoreString = (player.score..' !')
            end
            roobert_11:drawTextAligned(scoreString, 200, 25, kTextAlignment.center)
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
                    for j = #leader, i + 1, -1 do
                        leader[j] = leader[j - 1]
                    end
                    leader[i] = player.name..'-'..player.score
                    pd.datastore.write(leader, 'leaderboard', true)
                end
                if newHighScore then break end
            end
            state = 'GameOverMain'
        end
    elseif state == 'GameOverMain' then

        if player.score > highestScore then
            gfx.fillRoundRect(70, 15, 260, 175, 5)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            roobert_11:drawTextAligned('New High Score!', 200, 115, kTextAlignment.center)
            roobert_10:drawTextAligned('A - Continue', 200, 150, kTextAlignment.center)
        elseif newHighScore then
            gfx.fillRoundRect(70, 15, 260, 175, 5)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            roobert_11:drawTextAligned('High Score!', 200, 115, kTextAlignment.center)
            roobert_10:drawTextAligned('A - Continue', 200, 150, kTextAlignment.center)
        else
            gfx.fillRoundRect(100, 15, 200, 125, 5)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            roobert_10:drawTextAligned('A - Continue', 200, 115, kTextAlignment.center)
        end
        roobert_24:drawTextAligned('Game Over', 200, 25, kTextAlignment.center)
        roobert_11:drawTextAligned(player.score, 200, 75, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gameOver()
    elseif state == 'GameOverLeader' then
    elseif state == 'GameOverRestart' then
    end
end