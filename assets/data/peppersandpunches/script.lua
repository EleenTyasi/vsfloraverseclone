local hudAngleSad = true;
local beathahaslow = true;
local beep = 1;
local beepbeep = 1;

function onCreate()
    setProperty("healthBar.alpha", 0.5)
end

function onUpdate(elasped)
    songPos = getSongPosition()
    local currentBeat = (songPos/100)/(curBpm/163)
    currentBeat2 = (songPos / 1000) * (bpm / 140)
    setProperty('iconP2.angle',10 - 10 * math.cos((currentBeat2*4)*math.pi) )
    setProperty('iconP1.angle',-10 - -10 * math.cos((currentBeat2*4)*math.pi) )
    if hudAngleSad then
        setProperty('camHUD.y',0 - -15 * math.cos((currentBeat2*4)*math.pi) )
        setProperty('camGame.y',0 - -9 * math.cos((currentBeat2*0.2)*math.pi) )
        setProperty('camHUD.x',0 - -15 * math.cos((currentBeat2*2)*math.pi) )
        setProperty('camGame.x',0 - -9 * math.cos((currentBeat2*0.4)*math.pi) )
    end
    if angy then
        setProperty("dad.y", 270+(math.sin(currentBeat/0.1)*3))
        setProperty("dad.x", 0+(math.cos(currentBeat/0.1)*3))
        setProperty("iconP2.y", 570+(math.sin(currentBeat/0.1)*3))
	    setProperty("iconP2.x", 570+(math.cos(currentBeat/0.1)*3))
    end
end

function noteMiss()
end

function goodNoteHit()
end

function onBeatHit()
    if curBeat == 142 then
        angy = true
        function opponentNoteHit()
            health = getProperty('health')
                if getProperty('health') > 0.25 then
                setProperty('health', health- 0.01);
            end
        end
    end
end