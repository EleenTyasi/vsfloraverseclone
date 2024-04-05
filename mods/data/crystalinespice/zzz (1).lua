-- Made by HeroEyad




-- scroll beacuse i dont wanna fuck the settings up
local scroll = false

-- speeen
spin1 = 1
spin2 = 1
spin3 = 1
spin4 = 1

ttype = quadInOut
tTime = 0.6
tamount = 180.99 -- 360 angle makes it zero i think

function onCreate()
	if getPropertyFromClass('ClientPrefs', 'middleScroll') == true then
		scroll = true;
	elseif getPropertyFromClass('ClientPrefs', 'middleScroll') == false then
		setPropertyFromClass('ClientPrefs', 'middleScroll', true);
	end
end

function onUpdate(elapsed)

	-- go away ew opponent notes eww
	noteTweenAlpha('opp1', 0, 0, 0.001, quadInOut)
	noteTweenAlpha('opp2', 1, 0, 0.001, quadInOut)
	noteTweenAlpha('opp3', 2, 0, 0.001, quadInOut)
	noteTweenAlpha('opp4', 3, 0, 0.001, quadInOut)

	noteTweenX('opp1', 0, 10000, 0.001, quadInOut)
	noteTweenX('opp2', 1, 10000, 0.001, quadInOut)
	noteTweenX('opp3', 2, 10000, 0.001, quadInOut)
	noteTweenX('opp4', 3, 10000, 0.001, quadInOut)

	local songPos = getSongPosition()
	local curBpm = (songPos / 1000) * (bpm / 200)

	for i = 4, 7 do
		noteTweenY("waveywavey" .. i, i, defaultPlayerStrumY0 + 5 * math.cos((curBpm + i * 2.25) * math.pi), 0.001)
	end

end




function onDestroy()
	if scroll == false then
		setPropertyFromClass('ClientPrefs', 'middleScroll', false);
	elseif scroll == true then
		scroll = false;
	end
end


