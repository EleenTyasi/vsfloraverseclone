function onCreate()
	-- lua is weird. gotta snap BF's neck every time i wanna reload the lua
	makeLuaSprite('WBback', 'WBback', -225, -300);
	-- this is bad dumb code, and more importantly it's bad dumb code that makes no fucking sense
	setScrollFactor('WBback', 0.6, 0.6);
	-- try and scale this down to allow this to be a bit more visible
	scaleObject('WBback', 0.7, 0.7);
	-- what in the name of shit is this positioning??????
	makeLuaSprite('WBfront', 'WBfront', -600, 675);
	scaleObject('WBfront', 1.0, 1.0);


	addLuaSprite('WBback', false);
	addLuaSprite('WBfront', false);
	
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end