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

local debug = false
local select = 1

if not leader or debug then
    for i = 1, 5 do
        tempLeader[i] = ('Player-'..0)
    end
    pd.datastore.write(tempLeader, 'leaderboard', true)
    leader = tempLeader
end

class('Pause').extends(gfx.sprite)

function Pause:init(x, y, w, h)
    Pause.super.init(self)
    local img = gfx.image.new(w, h)
    gfx.pushContext(img)
        gfx.fillRect(x, y, w, h)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        roobert_24:drawTextAligned('Paused', 200, 100, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.popContext()
    self:setImage(img)
    self:setCenter(0, 0)
end

function pause()
    pd.ui.crankIndicator:update()
end

function clearSprites()
    gfx.sprite.removeAll()
    if spawnTimer then
        spawnTimer:remove()
    end
end

function borderText(w, h, borderY, stringY, fontSize, string)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.fillRoundRect((200 - w / 2), borderY, w, h, 5)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    if fontSize == 11 then
        roobert_11:drawTextAligned(string, 200, stringY, kTextAlignment.center)
    elseif fontSize == 24 then
        roobert_24:drawTextAligned(string, 200, stringY, kTextAlignment.center)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function plainText(y, fontSize, string)
    if fontSize == 11 then
        roobert_11:drawTextAligned(string, 200, y, kTextAlignment.center)
    elseif fontSize == 24 then
        roobert_24:drawTextAligned(string, 200, y, kTextAlignment.center)
    end
end

function showLeaderboard(center, y, player)
    local w = 150
    local h = 152
    local r = 5
    local x = center - (w / 2)
    gfx.fillRoundRect(x, y, w, h, r)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    for i = 1, #leader do
        if i == newHighScoreIndex then
            local input = pd.keyboard.text
            if string.len(input) > 10 then
                input = string.sub(input, 1, 10)
                pd.keyboard.text = input
            end
            roobert_10:drawTextAligned(i..'. '..input..' - '..player.score, center, (y - 7) + (i * 25), kTextAlignment.center)
        else
            local index = string.find(leader[i], '-')
            local name = string.sub(leader[i], 1, index - 1)
            local score = string.sub(leader[i], index + 1)
            local string = (i..'. '..name..' - '..score)
            roobert_10:drawTextAligned(string, center, (y - 7) + (i * 25), kTextAlignment.center)
        end
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function menu(state, player, spawnTimer)
    if state == 'Menu' then
        borderText(200, 50, 15, 25, 24, 'Slime Climb')
        if select == 1 then
            borderText(60, 25, 117, 120, 11, 'Start')
            plainText(145, 11, 'Leaderboard')
        elseif select == 2 then
            plainText(120, 11, 'Start')
            borderText(125, 25, 142, 145, 11, 'Leaderboard')
        end
        if pd.buttonJustPressed('down') then
            gfx.clear()
            select -= 1
        elseif pd.buttonJustPressed('up') then
            gfx.clear()
            select += 1
        end
        if select < 1 then select = 2
        elseif select > 2 then select = 1
        end
        if pd.buttonJustPressed('a') and select == 1 then
            startGame()
            highIndex = string.find(leader[1], '-')
            highestScore = string.sub(leader[1], highIndex + 1)
            highestScore = tonumber(highestScore)
            state = 'Game'
            gfx.clear()
        elseif pd.buttonJustPressed('a') and select == 2 then
            state = 'Leaderboard'
            gfx.clear()
        end
    elseif state == 'Leaderboard' then
        plainText(5, 24, 'High Scores')
        showLeaderboard(200, 50, player)
        borderText(105, 25, 212, 215, 11, 'Main Menu')
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        if pd.buttonJustPressed('a') then
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
            borderText(40, 40, 15, 25, 11, scoreString)
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
            gfx.fillRoundRect(70, 15, 260, 160, 5)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            roobert_11:drawTextAligned('New High Score!', 200, 115, kTextAlignment.center)
            roobert_10:drawTextAligned('A - Continue', 200, 150, kTextAlignment.center)
        elseif newHighScore then
            gfx.fillRoundRect(70, 15, 260, 160, 5)
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
        end
    elseif state == 'GameOverLeader' then
        local center, xVal
        if newHighScore then
            center = 110
        else
            center = 200
        end
        showLeaderboard(center, 5, player)
        function saveName(saved)
            if saved then
                leader[newHighScoreIndex] = pd.keyboard.text..'-'..player.score
                player.name = pd.keyboard.text
                pd.datastore.write(pd.keyboard.text, 'playerName', true)
            end
            newHighScoreIndex = nil
            pd.datastore.write(leader, 'leaderboard', true)
        end
        pd.keyboard.keyboardWillHideCallback = saveName
        if not newHighScore and pd.buttonJustPressed('a') or (newHighScoreIndex == nil) then
            state = 'GameOverRestart'
        end
    elseif state == 'GameOverRestart' then
        showLeaderboard(200, 5, player)
        local w = 150
        local h = 55
        gfx.fillRoundRect(200 - (w / 2), 220 - h, w, h, 5)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        roobert_10:drawTextAligned('A - Quick Restart', 200, 176, kTextAlignment.center)
        roobert_10:drawTextAligned('B - Main Menu', 200, 196, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        if pd.buttonJustPressed("a") then
            state = 'Game'
            newHighScore = false
            clearSprites()
            startGame()
            highIndex = string.find(leader[1], '-')
            highestScore = string.sub(leader[1], highIndex + 1)
            highestScore = tonumber(highestScore)
        elseif pd.buttonJustPressed('b') then
            newHighScore = false
            state = 'Menu'
            clearSprites()
        end
    end
    return state
end