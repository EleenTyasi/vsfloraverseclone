--this script will detect when there are/aren't notes on the player's and/or opponent's lanes (made by kornelbut, credit would be neat)

--no touchy these
local plNotes, opNotes = 0, 0
local nuhuh, nuhuh1 = false, false

--customizable variables here!!!!!!!!!!!!!!!!!!!!!!!!!!!!
local dontDoTheScript = false --set to true if you don't want this script to work
local plOnly = false --set to true if you only want player's strum to do this
local opOnly = false --set to true if you only want opponent's strum to do this
local dimMode = true --set to true to have strums dim
local hideMode = false --set to true to have strums hide

--for all modes
local appearSpeed = 1 --speed of strums appearing
local disappearSpeed = 0.3 --speed of strums disappearing

--for dim mode
local undimOpacity = 0.8 --opacity of strums when notes are on-screen
local dimOpacity = 0.1 --opacity of strums when notes aren't on-screen
local undimDuration = 0.25 --duration time for strums undimming
local dimDuration = 0.25 --duration time for strums dimming
local undimEase = 'sineOut'
local dimEase = 'sineOut'

--for hide mode
local showDuration = 0.7 --duration time for strums showing
local hideDuration = 0.7  --duration time for strums hiding
local showEase = 'smootherStepOut'
local hideEase = 'smootherStepIn'

function onCreate()
	--[[ if you put this file in the scripts folder but want it to behave differently in specific songs, remove the comment and change your songPath to your song's name and the variables accordingly
	if songPath == "insert your song data folder name" then
		insert variables
	end ]]
	if not dontDoTheScript then
		setProperty('skipArrowStartTween', true) 
	end
end

function onCreatePost()
	if not dontDoTheScript then
		if hideMode and not dimMode then
			for i = 0,3 do
				setPropertyFromGroup('playerStrums', i, 'alpha', 0.8)
				setPropertyFromGroup('opponentStrums', i, 'alpha', 0.8)
			end
		end
			for i = 0,3 do
				if not opOnly then
					if dimMode then
						setPropertyFromGroup('playerStrums', i, 'alpha', dimOpacity)
					end
						if hideMode then
							if not downscroll then
								setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i] - 200)
							else
								setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i] + 200)
							end
						end
				else
					if dimMode then
						setPropertyFromGroup('playerStrums', i, 'alpha', undimOpacity)
					end
						if hideMode then
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
						end
				end
					if not plOnly then
						if dimMode then
							setPropertyFromGroup('opponentStrums', i, 'alpha', dimOpacity)
						end
							if hideMode then
								if not downscroll then
									setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i] - 200)
								else
									setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i] + 200)			
								end
							end
					else
						if dimMode then
							setPropertyFromGroup('opponentStrums', i, 'alpha', undimOpacity)
						end
							if hideMode then
								setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i])
							end
					end
			end
	end
end

function onSpawnNote(id, direction, type, holdNote)
	if not dontDoTheScript and not getPropertyFromGroup('unspawnNotes', id, 'ignoreNote') then
		if not getPropertyFromGroup('unspawnNotes', id, 'mustPress') and not plOnly then
			opNotes = opNotes + 1
			if nuhuh == false then
				runTimer('opWait', appearSpeed, 1)
			end
			nuhuh = true
		elseif getPropertyFromGroup('unspawnNotes', id, 'mustPress') and not opOnly then
			plNotes = plNotes + 1
			if nuhuh1 == false then
				runTimer('plWait', appearSpeed, 1)
			end
			nuhuh1 = true
		end
	end
end

function goodNoteHit(id, direction, type, holdNote)
	if not dontDoTheScript and not opOnly and not getPropertyFromGroup('notes', id, 'ignoreNote') then
		plNotes = plNotes - 1
		runTimer('plStrum', disappearSpeed, 1)
	end
end

function noteMiss()
	if not dontDoTheScript and not opOnly then
		plNotes = plNotes - 1
		runTimer('plStrum', disappearSpeed, 1)
	end
end

function opponentNoteHit()
	if not dontDoTheScript and not plOnly then
		opNotes = opNotes - 1
		runTimer('opStrum', disappearSpeed, 1)
	end
end

function onTimerCompleted(tag)
	if tag == 'opStrum' and opNotes == 0 then
		detection('op', 'hide')
	elseif tag == 'plStrum' and plNotes == 0 then
		detection('pl', 'hide')
	elseif tag == 'opWait' then
		detection('op', 'show')
	elseif tag == 'plWait' then
		detection('pl', 'show')
	end
end

function detection(who, what)
	if who == 'pl' then
		if what == 'hide' then
			for i = 4,7 do
				if dimMode then
					noteTweenAlpha('pl'..i, i, dimOpacity, dimDuration, dimEase)
				end
					if hideMode then
						if not downscroll then
							noteTweenY('pl'..i, i, _G['defaultPlayerStrumY'..(i-4)] - 200, hideDuration, hideEase)
						else
							noteTweenY('pl'..i, i, _G['defaultPlayerStrumY'..(i-4)] + 200, hideDuration, hideEase)
						end
					end
			end
		else
			for i = 4,7 do
				if dimMode then
					noteTweenAlpha('pl'..i, i, undimOpacity, undimDuration, undimEase)
				end
					if hideMode then
						noteTweenY('pl'..i, i, _G['defaultPlayerStrumY'..(i-4)], showDuration, showEase)
					end
			end
			nuhuh1 = false
		end
	else
		if what == 'hide' then
			for i = 0,3 do
				if dimMode then
					noteTweenAlpha('op'..i, i, dimOpacity, dimDuration, dimEase)
				end
					if hideMode then
						if not downscroll then
							noteTweenY('op'..i, i, _G['defaultOpponentStrumY'..i] - 200, hideDuration, hideEase)
						else
							noteTweenY('op'..i, i, _G['defaultOpponentStrumY'..i] + 200, hideDuration, hideEase)
						end
					end
			end
		else
			for i = 0,3 do
				if dimMode then
					noteTweenAlpha('op'..i, i, undimOpacity, undimDuration, undimEase)
				end
					if hideMode then
						noteTweenY('op'..i, i, _G['defaultOpponentStrumY'..i], showDuration, showEase)
					end
			end
			nuhuh = false
		end
	end
end