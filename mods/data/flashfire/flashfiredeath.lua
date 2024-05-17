math.randomseed(os.time())
function onCreate()
	-- roll a 3 sided die.
	deathTauntRandom = getRandomInt(1,3)
	-- set up roll result, 1-3. play that sound when BF dies.
	-- man, RecD popped the heck off with his lines.
	-- I gave good voice direction, then i edited the sound to make it a bit like the character. 
	if deathTauntRandom == 1 then
		-- HOTHEAD: "Can't handle me at ONE PERCENT OF MY POWER?! God! Who wrote my lines?!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-whowrotemylines'); --put in mods/sounds/
	end
	if deathTauntRandom == 2 then
		-- HOTHEAD: "HAH! Get cooked, you blue furred punk!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-bluefurpunk'); --put in mods/sounds/
	end
	if deathTauntRandom == 3 then
		-- HOTHEAD: "Someone call fire control, cuz you just got BURNED!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-burned'); --put in mods/sounds/
	end
end