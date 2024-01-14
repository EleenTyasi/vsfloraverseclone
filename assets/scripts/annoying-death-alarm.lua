function onCreate()
    --precacheSound('pkmnhp')

    makeLuaSprite('alarm', 'ycr', 0, 0)
    setObjectCamera('alarm', 'hud')
    doTweenAlpha('alarming', 'alarm', 0, 0.1, 'linear')
    addLuaSprite('alarm')
end

function onCreatePost()
    --precacheSound('pkmnhp')
end


function onBeatHit()
    if getProperty('health') < 0.4 then
        --debugPrint('low hp')
        if curBeat % 2 == 0 then --if here is 4 then other is uncommented
            --debugPrint('on')
            stopSound('beep')
            playSound('low_health', 0.5, 'beep')
            doTweenAlpha('alarming', 'alarm', 1, crochet/1000, 'linear') --circin
        else--if curBeat % 2 == 0 then
            --debugPrint('off')
            doTweenAlpha('alarming', 'alarm', 0.5, crochet/1000, 'linear') --circout
        end
    else
        --stopSound('beep')
        doTweenAlpha('alarming', 'alarm', 0, 1, 'linear')
    end
end

function onUpdate(elapsed)
    --crochet = ((60/bpm)*1000)
    --debugPrint(crochet/1000)

    if getProperty('health') < 0.4 then
        --doTweenAlpha('hpon', 'alarm', 1, crochet/1000, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag == "hpon" then
        doTweenAlpha('hpoff', 'alarm', 0, crochet/1000, 'linear')
    elseif tag == "hpoff" then
        doTweenAlpha('hpon', 'alarm', 1, crochet/1000, 'linear')
    end
end

function onResume()
    resumeSound('beep')
end

function onPause()
    pauseSound('beep')
end