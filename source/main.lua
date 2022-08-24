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

math.randomseed(pd.getSecondsSinceEpoch())

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

end

function leaderboard()

end

function startGame()
    player = Player(slimeAnim, 100, 185, 15)
    current = level(player)
    spawnTimer = pd.timer.keyRepeatTimerWithDelay(5000, 5000, spawnBlock)
    highIndex = string.find(leader[1], '-')
    highestScore = string.sub(leader[1], highIndex + 1)
    highestScore = tonumber(highestScore)
end

function gameOver()
    if pd.buttonJustPressed('a') then
        gfx.clear()
        gameState = 'gameOverLeader'
    end
end

function game()
    if player.alive then
        scroll(current)
    else
    end
end



function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
    
    game()


    menu(gameState, player, leader)

end