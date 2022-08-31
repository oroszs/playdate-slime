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
import "ui"

local pd <const> = playdate
local gfx <const> = pd.graphics
local current, player, score, crankUI, spawnTimer, playerName
local spawning = false
local slimeAnim = gfx.imagetable.new("images/slime-anim")
local gameState = 'Menu'

math.randomseed(pd.getSecondsSinceEpoch())

function startGame()
    player = Player(slimeAnim, 100, 185, 15)
    playerName = pd.datastore.read('playerName')
    if playerName then
        player.name = playerName
    end
    current = level(player)
    spawnTimer = pd.timer.new(5000)
    spawnTimer.repeats = true
    spawnTimer.timerEndedCallback = spawnBlock
    spawnBlock()
end

function crankCheck(state)
    if pd.isCrankDocked() then
        if not (state == 'Pause') then
            state = 'Pause'
            pd.ui.crankIndicator:start()
            spawnTimer:pause()
            spawning = false
        end
    else
        if (state == 'Pause') then
            state = 'Game'
            spawning = true
            spawnTimer:start()
        end
    end
    return state
end

function game()
    if gameState == 'Game' and player.alive then
        scroll(current)
    end
    if (gameState == 'Game') or (gameState == 'Pause') and player.alive then
        gameState = crankCheck(gameState)
    end
end

function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
    game()
    gameState = menu(gameState, player, spawnTimer)
end