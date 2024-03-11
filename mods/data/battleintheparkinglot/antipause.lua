-- The antipause script from the Sculscripts pack.
-- If the player tries to pause the game by regular
-- means, they won't be able to and a message will appear.

-- Recently as of 1.1.0, a new variable for antipause was introduced:
-- antiunfocus. When true, if the player removes the focus from the
-- game, the game will still play as regularly regardless if it's focused
-- on or not. By default it is true, but you may set it to false if you'd
-- like.

local antiunfocus = true

-- onCreate is automatically called when you enter a song and it starts loading. 
function onCreate()
	-- Checks if antiunfocus is true or not.
	if antiunfocus == true then
		-- Disables the autoPause property in flixel.FlxG automatically when the 
		setPropertyFromClass('flixel.FlxG', 'autoPause', false)
	end
end

-- When you exit the song or the song ends, call onDelete.
function onDelete()
	-- Automatically sets autoPause back to true.
	setPropertyFromClass('flixel.FlxG', 'autoPause', true)
end

-- When paused, call onPause.
function onPause()
	-- Creates the text.
	-- The values are in order: the message tag, text to display, text width, the x position, and the y position.
	makeLuaText('antipause', 'You cannot pause now, There is an enemy nearby!', 100, 580, 360)
	-- Displays the message. After it has been displayed, it runs a timer,
	-- that when finished, will remove the message from the screen.
	addLuaText('antipause')
	runTimer('antipausetimer', 1, 1)
	-- Disables the pause menu.
	return Function_Stop
end

-- When the removal timer finishes, call onTimerCompleted.
function onTimerCompleted(antipausetimer)
	-- Removes the message.
	removeLuaText('antipause', false)
end