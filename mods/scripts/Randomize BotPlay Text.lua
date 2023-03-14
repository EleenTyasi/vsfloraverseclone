function onCreatePost()
        botplayTxtRandom = getRandomInt(1,30)
end

function onUpdate()
        screenCenter('botplayTxt', 'x')
        setTextSize('botplayTxt', 35)
        
        if not downscroll then
        setProperty("botplayTxt.y", 590)
        elseif downscroll then
        setProperty("botplayTxt.y", 104)
        end

        if botplayTxtRandom == 1 then
        setTextString("botplayTxt", "no score will be saved.")
        end
        if botplayTxtRandom == 2 then
        setTextString("botplayTxt", "Aw, beans. No score will be saved!")
        end
        if botplayTxtRandom == 3 then
        setTextString("botplayTxt", "HEY PLAYER. STOP USING BOTPLAY.")
        end
        if botplayTxtRandom == 4 then
        setTextString("botplayTxt", "Ah, Botplay.")
        end
        if botplayTxtRandom == 5 then
        setTextString("botplayTxt", "Try disabling botplay!")
        end
        if botplayTxtRandom == 6 then
        setTextString("botplayTxt", "No score will be saved. Try disabling Botplay!")
        end
        if botplayTxtRandom == 7 then
        setTextString("botplayTxt", "Degreeless Mode")
        end
        if botplayTxtRandom == 8 then
        setTextString("botplayTxt", "Shoutouts to Simpleflips")
        end
        if botplayTxtRandom == 9 then
        setTextString("botplayTxt", "TALwire Mode - No score will be saved.")
        end
        if botplayTxtRandom == 10 then
        setTextString("botplayTxt", "lol no score 4 u - turn off botplay")
        end
        if botplayTxtRandom == 11 then
        setTextString("botplayTxt", "No way? No way! No way? No way!")
        end
        if botplayTxtRandom == 12 then
        setTextString("botplayTxt", "No score will be saved.")
        end
        if botplayTxtRandom == 13 then
        setTextString("botplayTxt", "CONTROLLER DISCONNECTED - PLEASE RECONNECT PLAYER 1")
        end
        if botplayTxtRandom == 14 then
        setTextString("botplayTxt", "Just like the animations?")
        end
        if botplayTxtRandom == 15 then
        setTextString("botplayTxt", "What, no score?")
        end
        if botplayTxtRandom == 16 then
        setTextString("botplayTxt", "No shame here. No score will be saved.")
        end
        if botplayTxtRandom == 17 then
        setTextString("botplayTxt", "Just wanna vibe?")
        end
        if botplayTxtRandom == 18 then
        setTextString("botplayTxt", "No score here. Only geese.")
        end
        if botplayTxtRandom == 19 then
        setTextString("botplayTxt", "Dang. No score will be saved.")
        end
        if botplayTxtRandom == 20 then
        setTextString("botplayTxt", "Auto Play - No score will be saved.")
        end
        if botplayTxtRandom == 21 then
        setTextString("botplayTxt", "Botplay - No score will be saved.")
        end
        if botplayTxtRandom == 22 then
        setTextString("botplayTxt", "No Player Detected - No score will be saved.")
        end
        if botplayTxtRandom == 23 then
        setTextString("botplayTxt", "Bot Mode - No score will be saved.")
        end
        if botplayTxtRandom == 24 then
        setTextString("botplayTxt", "You thought you were getting score, but it was I, BOTPLAY!")
        end
        if botplayTxtRandom == 25 then
        setTextString("botplayTxt", "ChatGPT is playing for you - No Score Will be Saved")
        end
        if botplayTxtRandom == 26 then
        setTextString("botplayTxt", "The machine uprising begins. Your score will be confiscated and paid as protection tax to the robo-mafiosos.")
        end
        if botplayTxtRandom == 27 then
        setTextString("botplayTxt", "Is botplay! Is nice.")
        end
        if botplayTxtRandom == 28 then
        setTextString("botplayTxt", "i eat ur score om nom nom")
        end
        if botplayTxtRandom == 29 then
        setTextString("botplayTxt", "SCORE IS DED! is nice.")
        end
        if botplayTxtRandom == 30 then
        setTextString("botplayTxt", "I declare your score zero!")
        end
end