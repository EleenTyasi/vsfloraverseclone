-- Script by AquaStrikr (https://twitter.com/AquaStrikr_)
function onCreatePost()
	makeLuaSprite('Health', 'healthbarSacorg')
	setObjectCamera('Health', 'hud')
	addLuaSprite('Health', true)
	setObjectOrder('Health', getObjectOrder('healthBar') + 1)
	setProperty('healthBar.visible', true)
end

function onUpdatePost(elapsed)
	setProperty('Health.visible', getProperty('scoreTxt.visible'))
	setProperty('Health.alpha', getProperty('scoreTxt.alpha'))
	setProperty('Health.x', getProperty('healthBar.x') - 28)
	setProperty('Health.y', getProperty('healthBar.y') - 20)
end