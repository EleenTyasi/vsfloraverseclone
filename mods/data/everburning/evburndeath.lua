math.randomseed(os.time())
function onCreate()
	-- roll a 3 sided die.
	deathTauntRandom = getRandomInt(1,3)
	-- set up roll result, 1-3. play that sound when BF dies.
	-- man, RecD popped the heck off with his lines.
	-- I gave good voice direction, then i edited the sound to make it a bit like the character. 
	if deathTauntRandom == 1 then
		-- HOTHEAD: "Oh my god?! You look like death warmed over!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-dwo'); --put in mods/sounds/
	end
	if deathTauntRandom == 2 then
		-- HOTHEAD: "I guess you could say- ELEEN! I'm not making another fire pun!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-nomorepuns'); --put in mods/sounds/
	end
	if deathTauntRandom == 3 then
		-- HOTHEAD: "Finally you shut the hell up!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-sthu'); --put in mods/sounds/
	end
end