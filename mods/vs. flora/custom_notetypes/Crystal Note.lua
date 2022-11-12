function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Crystal Note' then  --Checks if the note is the one in the script. Set this to the name of your file.
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'CRYSTNOTE_assets'); --Changes the texture to your own
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '-0.008'); --Default is 0.023, sets the value you get on hit
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', '0.044'); --Default is 0.0475, sets the value you get on miss
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', false);

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has no penalties
			end
		end
	end
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false
function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Crystal Note' then
		-- put something here if you want
	end
end

-- Called after the note miss calculations
-- Player missed a note by letting it go offscreen
function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Crystal Note' then
		-- put something here if you want
	end
end