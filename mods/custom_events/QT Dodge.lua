local Warn = 0;
local DodgeAmount = "one";
local TickAmount = "two";
local Ended = false;
local doinYourMom = false;
local durationTimer = 0.125;
local dodgeWindowTimer = 0.2;
local dodging = false;
local attacking = false;
local attacked = false;
local pressureVar = 0.01;
function onCreate()
		makeAnimatedLuaSprite('warn', 'qt/attack_alert_NEW', 0, 0)
		addAnimationByPrefix('warn', 'one', 'kb_attack_animation_alert-single0', 24, false)
		addAnimationByPrefix('warn', 'two', 'kb_attack_animation_alert-double0', 24, false)
		addAnimationByPrefix('warn', 'three', 'kb_attack_animation_alert-triple0', 24, false)
		addAnimationByPrefix('warn', 'four', 'kb_attack_animation_alert-quad0', 24, false)
		setObjectCamera('warn', 'hud')
		screenCenter('warn')
		addLuaSprite('warn', false)
		setProperty("warn.alpha", 0)
		
		makeAnimatedLuaSprite('attack', 'qt/attackv6', -2060, 410)
		setObjectCamera('attack', 'hud')
		addAnimationByPrefix('attack', 'fire', 'kb_attack_animation_fire', 24, false)
		addLuaSprite('attack', false)
		setProperty("attack.alpha", 0)
	end	

function onEvent(name, value1, value2)
	if name == "QT Dodge" then
		DodgeAmount = value1
		TickAmount = value2
		Warn = 0
		Ended = false
		doinYourMom = true
	end
end

function onUpdatePost()
	if getPropertyFromClass('flixel.FlxG',"keys.pressed.SPACE") then
		if dodging == false then
			dodging = true
			characterPlayAnim('boyfriend', 'dodge', true);
			runTimer("dodgeTimer", dodgeWindowTimer)
			playSound("dodge01", 1)
		end
	end
	if Ended == true then
		doinYourMom = false
	end
end



function attack(attackSound, stop)
	runTimer("attackTimer", durationTimer)
	playSound(attackSound, 0.5)
	objectPlayAnimation('attack', 'fire', true)
	setProperty("attack.alpha", 1)
	attacking = true
	if stop == true then
		Ended = true
	end
end

function warning(alertSound, animation)
	playSound(alertSound, 0.5)
	setProperty("warn.alpha", 1)
	objectPlayAnimation('warn', animation, true)
end

function onBeatHit()
	if Ended == false then
		Warn = Warn + 1;
	end
	if doinYourMom == true then
		if DodgeAmount == "one" then
			if Warn == 1 then
				warning("alert", "one")
			elseif Warn == 2 then
				warning("alert", "one")
			elseif Warn == 3 then
				attack("attack", true)
			end
		elseif DodgeAmount == "two" then
			if Warn == 1 then
				warning("alert", "one")
			elseif Warn == 2 then
				warning("alertALT", "two")
			elseif Warn == 3 then
				attack("attack", false)
			elseif Warn == 4 then
				attack("attackALT", true)
			end
		elseif DodgeAmount == "three" then
			if Warn == 1 then
				warning("alert", "one")
			end
			if TickAmount == "two" then
				if Warn == 2 then
					warning("alertALT2", "three")
				elseif Warn == 3 then
					attack("attack", false)
				elseif Warn == 4 then
					attack("attackALT", false)
				elseif Warn == 5 then
					attack("attackALT2", true)
				end
			else
				if Warn == 2 then
					warning("alertALT", "two")
				elseif Warn == 3 then
					warning("alertALT2", "three")
				elseif Warn == 4 then
					attack("attack", false)
				elseif Warn == 5 then
					attack("attackALT", false)
				elseif Warn == 6 then
					attack("attackALT2", true)
				end
			end
		elseif DodgeAmount == "four" then
			if Warn == 1 then
				warning("alert", "one")
			end
			if TickAmount == "two" then
				if Warn == 2 then
					warning("alertALT3", "four")
				elseif Warn == 3 then
					attack("attack", false)
				elseif Warn == 4 then
					attack("attackALT", false)
				elseif Warn == 5 then
					attack("attackALT2", false)
				elseif Warn == 6 then
					attack("attackALT3", true)
				end
			elseif TickAmount == "three" then
				if Warn == 2 then
					warning("alertALT", "two")
				elseif Warn == 3 then
					warning("alertALT3", "four")
				elseif Warn == 4 then
					attack("attack", false)
				elseif Warn == 5 then
					attack("attackALT", false)
				elseif Warn == 6 then
					attack("attackALT2", false)
				elseif Warn == 7 then
					attack("attackALT3", true)
				end
			else
				if Warn == 2 then
					warning("alertALT", "two")
				elseif Warn == 3 then
					warning("alertALT2", "three")
				elseif Warn == 4 then
					warning("alertALT3", "four")
				elseif Warn == 5 then
					attack("attack", false)
				elseif Warn == 6 then
					attack("attackALT", false)
				elseif Warn == 7 then
					attack("attackALT2", false)
				elseif Warn == 8 then
					attack("attackALT3", true)
				end
			end
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'dodgeTimer' then
		dodging = false
	end
	if tag == 'attackTimer' then
		if not getProperty("cpuControlled") == true then -- if the player isn't playing botplay, then...
			if dodging == false then -- if the player failed to dodge...
				health = getProperty('health') -- get the player's health.
				setProperty('health',  health - (pressureVar * 2.8)); -- Hit them with a pressure based attack. 
				pressureVar = pressureVar + 0.028; -- penalize by increasing pressure too.
				if pressureVar >= 0.4 then -- if pressure is at 0.4 or greater...
					health = getProperty('health') -- get the victim's health.
					setProperty('health',  0); -- slaughter the player like a pig. Kill them. Dead.
				end
			end
			if dodging == true then -- if the player dodged...
				setProperty('health', health + 0.002); -- reward them. this does not affect pressure.
			end
		end
	end
end