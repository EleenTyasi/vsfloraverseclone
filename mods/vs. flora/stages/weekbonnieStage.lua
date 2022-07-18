function onCreate()
	-- lua is weird. gotta snap BF's neck every time i wanna reload the lua
	makeLuaSprite('WBback', 'WBback', -150, -250);
	setScrollFactor('WBback', 0.5, 0.5);
	-- try and scale this down to allow this to be a bit more visible
	scaleObject('WBback', 0.8, 0.8);

	makeLuaSprite('WBfront', 'WBfront', -600, 600);
	setScrollFactor('WBfront', 0.9, 0.9);
	scaleObject('WBfront', 1.1, 1.1);


	addLuaSprite('WBback', false);
	addLuaSprite('WBfront', false);
	
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end