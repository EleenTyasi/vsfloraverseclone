local pressure = 0.01
function onCountdownStarted()
    debugPrint("Current difficulty: " .. tostring(difficulty))  -- Debugging line to check the difficulty being fetched
    if difficulty == 0 then
        pressure = pressure + 0.00
        debugPrint("Is this set to Easy? It should be 0.01.")
    elseif difficulty == 1 then
        pressure = pressure + 0.01
        debugPrint("Is this set to Normal? It should be 0.02.")
    elseif difficulty == 2 then
        pressure = pressure + 0.02
        debugPrint("Is this set to Hard? It should be 0.03.")
    elseif difficulty == 3 then
        pressure = pressure + 0.03
        debugPrint("Is this set to Hellsider? It should be 0.04.")
    end
    debugPrint("Pressure set to: " .. tostring(pressure))  -- Debugging line to check the pressure value after the difficulty check. FUCK me if this doesn't work
end

function noteMiss()
    if pressure >= 0.01 then
        if difficulty == 0 then
            pressure = pressure + 0.01
        elseif difficulty == 1 then
            pressure = pressure + 0.02
        elseif difficulty == 2 then
            pressure = pressure + 0.02
        elseif difficulty == 3 then
            pressure = pressure + 0.03
        end
    end;
end
function onUpdatePost(elasped)
    setTextString('scoreTxt', 'Score: '.. score .. ' | Misses: '.. misses .. ' | Combo Quality: '.. ratingName..' ('.. ratingFC ..') | Pressure: '.. pressure ..'pon')
end

function goodNoteHit()

end

function onBeatHit()
        function opponentNoteHit()
            health = getProperty('health')
            if getProperty('health') > 0.45 then
                setProperty('health', health-(pressure * 0.5));
                
            end
        end
end