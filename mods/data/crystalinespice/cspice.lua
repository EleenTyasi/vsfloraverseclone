GameTitleStart = '??? (Psych Engine) - Crystaline Spice' --game title thith song start
GameOverTitle = '??? (Psych Engine) - Game over...' --game over title
looseTitle = '??? (Psych Engine) - Crystaline Spice' --looser title(if you have < 1 health)
maxLooseMisses = 1 --max loose misses
perfectTitle = '??? (Psych Engine) - Crystaline Spice - PFC'

function onCreate()
    setPropertyFromClass("openfl.Lib", "application.window.title", GameTitleStart)
end

function onUpdate()
    if getProperty("health") < 0 then
        setPropertyFromClass("openfl.Lib", "application.window.title", GameOverTitle)
	elseif getProperty("songMisses") > maxLooseMisses then
        setPropertyFromClass("openfl.Lib", "application.window.title", looseTitle)
	elseif ratingName == 'Perfect!!' then
        setPropertyFromClass("openfl.Lib", "application.window.title", perfectTitle)
    end
end
-- script by maxida --