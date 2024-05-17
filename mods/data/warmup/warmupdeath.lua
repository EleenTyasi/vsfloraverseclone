math.randomseed(os.time())
function onCreate()
	-- roll a 3 sided die.
	deathTauntRandom = getRandomInt(1,3)
	-- set up roll result, 1-3. play that sound when BF dies.
	-- man, RecD popped the heck off with his lines.
	-- I gave good voice direction, then i edited the sound to make it a bit like the character. 
	if deathTauntRandom == 1 then
		-- HOTHEAD: "Seriously? I'm not even heated up yet!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-heatedyet'); --put in mods/sounds/
	end
	if deathTauntRandom == 2 then
		-- HOTHEAD, bewildered: "You cannot be serious. How can those arrows even do that?!"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-arrows'); --put in mods/sounds/
	end
	if deathTauntRandom == 3 then
		-- HOTHEAD, Smug: "Went a little to close to the sun...?"
		setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'hothead-icarus'); --put in mods/sounds/
	end
end