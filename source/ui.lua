import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import 'CoreLibs/keyboard'
import "main"

local pd <const> = playdate
local gfx <const> = pd.graphics

local roobert_10 <const> = gfx.font.new('fonts/Roobert/Roobert-10-Bold')
local roobert_11 <const> = gfx.font.new('fonts/Roobert/Roobert-11-Medium')
local roobert_20 <const> = gfx.font.new('fonts/Roobert/Roobert-20-Medium')
local roobert_24 <const> = gfx.font.new('fonts/Roobert/Roobert-24-Medium')

local highIndex, highestScore, newHighScoreIndex
local newHighScore = false
local leader = pd.datastore.read('leaderboard')
local tempLeader = {}

local debug = true

if not leader or debug then
    for i = 1, 5 do
        tempLeader[i] = ('Player-'..0)
    end
    pd.datastore.write(tempLeader, 'leaderboard', true)
    leader = tempLeader
end

function pause()
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    roobert_24:drawTextAligned('Paused', 200, 100, kTextAlignment.center)
    pd.ui.crankIndicator:update()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function clearSprites()
    gfx.sprite.removeAll()
    if spawnTimer then
        spawnTimer:remove()
    end
end

function menu(state, player, spawnTimer)
    if state == 'Menu' then

        roobert_24:drawTextAligned('Slime Climb', 200, 25, kTextAlignment.center)
        roobert_11:drawTextAligned('A - Start', 200, 120, kTextAlignment.center)
        roobert_11:drawTextAligned('B - Leaderboard', 200, 145, kTextAlignment.center)

        if pd.buttonJustPressed('a') then
            startGame()
            highIndex = string.find(leader[1], '-')
            highestScore = string.sub(leader[1], highIndex + 1)
            highestScore = tonumber(highestScore)
            state = 'Game'
            gfx.clear()
        elseif pd.buttonJustPressed('b') then
            state = 'Leaderboard'
            gfx.clear()
        end
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

    elseif state == 'Pause' then
        pause()
    elseif state == 'Game' then
        if player.alive then
            local scoreString = player.score
            if player.score > highestScore then
                scoreString = (player.score..' !')
            end
            roobert_11:drawTextAligned(scoreString, 200, 25, kTextAlignment.center)
        else
            spawnTimer:pause()
            for i = 1, #leader do
                local index = string.find(leader[i], '-')
                local score = string.sub(leader[i], index + 1)
                score = tonumber(score)
                if player.score > score then
                    newHighScore = true
                    newHighScoreIndex = i
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
        if pd.buttonJustPressed('a') then
            if newHighScore then
                pd.keyboard.show(player.name)
            end
            state = 'GameOverLeader'
            gfx.clear()
        end
    elseif state == 'GameOverLeader' then
        local center, xVal
        if newHighScore then
            center = 215 / 2
            xVal = 25
        else
            xVal = 115
            center = 200
        end
        gfx.fillRoundRect(xVal, 15, 170, 195, 5)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        for i = 1, #leader do
            if i == newHighScoreIndex then
                local input = pd.keyboard.text
                if string.len(input) > 10 then
                    input = string.sub(input, 1, 10)
                    pd.keyboard.text = input
                end
                roobert_10:drawTextAligned(i..'. '..input..' - '..player.score, center, 10 + (i * 31), kTextAlignment.center)
            else
                local index = string.find(leader[i], '-')
                local name = string.sub(leader[i], 1, index - 1)
                local score = string.sub(leader[i], index + 1)
                local string = (i..'. '..name..' - '..score)
                roobert_10:drawTextAligned(string, center, 10 + (i * 31), kTextAlignment.center)
            end
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    elseif state == 'GameOverRestart' then
        if pd.buttonJustPressed("a") then
            newHighScore = false
            clearSprites()
            startGame()
        elseif pd.buttonJustPressed('b') then
            newHighScore = false
            state = 'Menu'
            clearSprites()
        end
    end
    return state
end