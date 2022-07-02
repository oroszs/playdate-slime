import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "libraries/AnimatedSprite.lua"

local pd <const> = playdate
local gfx <const> = pd.graphics

local slimeSprite = nil
local playerSpeed = 2

function spriteSetup()

    local slimeTable = gfx.imagetable.new("images/slime")
    slimeSprite = AnimatedSprite.new(slimeTable)
    slimeSprite:addState("Idle", 1, 6, {tickStep = 2})
    slimeSprite:playAnimation()
    slimeSprite:moveTo(200, 120)


end

function bgSetup()
    
    local backgroundImage = gfx.image.new("images/checkered-bg")
    local ditherType = gfx.image.kDitherTypeBurkes
    local radius = 2
    local numPasses = 1
    local blurredBG = backgroundImage:blurredImage(radius, numPasses, ditherType)
    local alpha = .5
    local fadedBG = blurredBG:fadedImage(alpha, ditherType)
    assert (fadedBG)

    gfx.sprite.setBackgroundDrawingCallback(
        function (x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            fadedBG:draw(0,0)
            gfx.clearClipRect()
        end
    )

end

function setup()

    spriteSetup()
    bgSetup()

end

setup()


function playdate.update()

    gfx.sprite.update()

end