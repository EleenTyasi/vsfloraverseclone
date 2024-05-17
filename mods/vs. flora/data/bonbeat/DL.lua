local allowCountdown = false

function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if (not allowCountdown and isStoryMode and not seenCutscene) then --
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		allowCountdown = true;
		seenCutscene = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		--triggerEvent('dialogue.setSkin', 'myskin', ''); --'default' skin is active by default
		triggerEvent('startDialogue', 'dialogue', 'breakfast'); --value1: dialogue file name, value2: music file name (can be left blank)
	end
end

--Uncomment this to see what events are processed
--[[function onEvent(name, value1, value2)
	if (name:startsWith('dialogue.') or name == 'startDialogue') then
		debugPrint('IN: onEvent("'..name..'", "'..value1..'", "'..value2..'")');
	end
end

function string.startsWith(String, Start)
   return string.sub(String, 1, string.len(Start))==Start
end]]--