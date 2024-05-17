local pressure = 0.01 
math.randomseed(os.time())
function onCountdownStarted()
    EggRoll = math.random(100)
    debugPrint("Current difficulty: " .. tostring(difficulty))  -- Debugging line to check the difficulty being fetched
    if difficulty == 0 then -- If easy, pressure is 0.01
        pressure = pressure + 0.00
        debugPrint("Is this set to Easy? It should be 0.01.")
    elseif difficulty == 1 then -- If normal, pressure is 0.02
        pressure = pressure + 0.01
        debugPrint("Is this set to Normal? It should be 0.02.")
    elseif difficulty == 2 then -- If hard, pressure is 0.03
        pressure = pressure + 0.02
        debugPrint("Is this set to Hard? It should be 0.03.")
    elseif difficulty == 3 then -- If hellsider, pressure is 0.04
        pressure = pressure + 0.03
        debugPrint("Is this set to Hellsider? It should be 0.04.")
    end
    if difficulty == 3 then -- if on hellsider, roll a 100 sided die. if exactly 69, add a nuts amount of pressure.
        debugPrint("EggRoll is: " .. tostring(EggRoll))  -- Debugging line to check the EggRoll value after the difficulty is checked.
        if EggRoll == 69 then -- If the Egg Roll is EXACTLY 69, add .65 to the pressure. 
            pressure = pressure + 0.65
            debugPrint("EggRoll is 69! Pressure is now: " .. tostring(pressure))  -- Debugging line to check the pressure value after the EggRoll check.
        else 
            debugPrint("Roll not successful.")
        end
    end
    debugPrint("Pressure set to: " .. tostring(pressure))  -- Debugging line to check the pressure value after the difficulty check. 
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
            if getProperty('health') > 0.65 then
                setProperty('health', health-(pressure * 0.55));
                
            end
        end
end