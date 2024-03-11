GameTitleStart = 'Vs. Floraverse (Psych Engine) - Peppers And Punches' --game title thith song start
GameOverTitle = 'Vs. Floraverse (Psych Engine) - You got bamboozled.' --game over title
looseTitle = 'Vs. Floraverse (Psych Engine) - Peppers And Punches' --looser title(if you have < 1 health)
maxLooseMisses = 1 --max loose misses
perfectTitle = 'Vs. Floraverse (Psych Engine) - Peppers And Punches - FC'

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