-- Set the pressure to 0.01.
local pressure = 0.01
-- On missing, check if the pressure is greater than or equal to 0.01. If it is, add 0.021 to the pressure.
function noteMiss()
    if pressure >= 0.01 then
        pressure = pressure + 0.022;
    end
end
-- On the player hitting a note, do nothing...
function goodNoteHit()

end
-- On the opponent hitting a note, check if the player's health is greater than 0.35. If it is, subtract the pressure multiplied by 0.85 from the player's health.
function onBeatHit()
        function opponentNoteHit()
            health = getProperty('health')
            if getProperty('health') > 0.35 then
                setProperty('health', health-(pressure * 0.85));
            -- If the pressure exceeds 3, set the player's health to 0.01. This typically leads to a game over.
            if pressure == 3 then
                setProperty('health', 0.01)
            end
           end
        end
end