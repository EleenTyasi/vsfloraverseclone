pressure = 0.08;
function noteMiss()
    if pressure >= 0.01 then
        pressure = pressure + 0.033;
    end
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
                setProperty('health', health-(pressure * 0.5 * healthLossMult));
            end
        end
end