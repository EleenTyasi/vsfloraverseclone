function onCreate()
	-- lua is weird. gotta snap BF's neck every time i wanna reload the lua
	makeLuaSprite('nmbonstage', 'nmbonstage', -250, -300);
	-- this is bad dumb code, and more importantly it's bad dumb code that makes no fucking sense
	setScrollFactor('nmbonstage', 0.6, 0.6);
	-- try and scale this down to allow this to be a bit more visible
	scaleObject('nmbonstage', 0.85, 0.85);
	-- what in the name of shit is this positioning?????? 
	makeLuaSprite('nmbbase', 'nmbbase', -600, 675);
	scaleObject('nmbbase', 1.0, 1.0);


	addLuaSprite('nmbonstage', false);
	addLuaSprite('nmbbase', false);
	
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end