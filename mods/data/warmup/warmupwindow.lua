GameTitleStart = 'Vs. Floraverse (Psych Engine) - Warmup' --game title thith song start
GameOverTitle = 'Vs. Floraverse (Psych Engine) - You had to get out of the kitchen.' --game over title
looseTitle = 'Vs. Floraverse (Psych Engine) - Warmup' --looser title(if you have < 1 health)
maxLooseMisses = 1 --max loose misses
perfectTitle = 'Vs. Floraverse (Psych Engine) - Warmup - PFC'

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