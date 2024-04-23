local dad = false
local bf = false

function onCreatePost()
	makeLuaText('text', '',550,0,0)
	setObjectCamera('text', 'other')
	setProperty('text.alpha',1)
setObjectCamera('text','hud')
setTextFont('text','AE.ttf')
	setTextSize('text',25)
screenCenter('text','xy')
addLuaText('text',true)
end

function onUpdate()
if downscroll == false then
setProperty('text.y',getProperty('iconP2.y')-5)
else
	setProperty('text.y',getProperty('iconP2.y')+145)
end
setProperty('text.angle',getProperty('iconP2.angle',-2.5))

if dad == true and bf == false then
	setProperty('text.x',getProperty('iconP2.x')-225)
elseif dad == false and bf == true then
	setProperty('text.x',getProperty('iconP1.x')-50)
end
end

function onEvent(n,v1,v2)
	if n == 'Blam_lyrics' then
	if v2 == 'dad' then
		setProperty('text.color', getIconColor('dad'))
setProperty('text.alpha',1)
		doTweenColor('text0hi','text','FFFFFF',1)
		runTimer('bye',1.25)
		setTextString('text',v1)
	dad = true
	bf = false
	elseif v2 == 'bf' then
		setProperty('text.color', getIconColor('boyfriend'))
		setProperty('text.alpha',1)
		doTweenColor('text0hi','text','FFFFFF',1)
		runTimer('bye',1.25)
		setTextString('text',v1)
		dad = false
		bf = true
	end
end
end

function onTimerCompleted(tag)
if tag == 'bye' then
	doTweenAlpha('0bye','text',0,0.5)
end
end

function getIconColor(chr)
	return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end