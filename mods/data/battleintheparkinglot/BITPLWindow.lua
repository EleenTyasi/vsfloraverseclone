GameTitleStart = 'Vs. Gravity Break (Psych Engine) - Battle In The Parking Lot' --game title thith song start
GameOverTitle = 'Vs. Gravity Break (Psych Engine) - INSERT COIN?' --game over title
looseTitle = 'Vs. Gravity Break (Psych Engine) - Battle In The Parking Lot' --looser title(if you have < 1 health)
maxLooseMisses = 1 --max loose misses
perfectTitle = 'Vs. Gravity Break (Psych Engine) - Battle In The Parking Lot - FC'

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