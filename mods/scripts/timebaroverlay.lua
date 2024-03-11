function onCreatePost()
	makeLuaSprite('Time', 'timebarovr')
	setObjectCamera('Time', 'hud')
	addLuaSprite('Time', true)
	setObjectOrder('Time', getObjectOrder('timeBar') + 1)
	setProperty('timeBar.visible', true)
end

function onUpdatePost(elapsed)
	setProperty('Time.visible', getProperty('scoreTxt.visible'))
	setProperty('Time.alpha', getProperty('scoreTxt.alpha'))
	setProperty('Time.x', getProperty('timeBar.x') - 25)
	setProperty('Time.y', getProperty('timeBar.y') - 25)
end