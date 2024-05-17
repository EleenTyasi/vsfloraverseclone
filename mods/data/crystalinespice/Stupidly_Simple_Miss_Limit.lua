math.randomseed(os.time())
local misslimit = math.random(4,8) -- You can set this to any number you want!

function onUpdatePost(elasped)
    setTextString('scoreTxt', 'Score: '.. score .. ' | '.. misses .. '/'.. misslimit .. ' | Combo Quality: '.. ratingName..' ('.. ratingFC ..')')
end

function onUpdate(elapsed)
    if misses > misslimit then
        setProperty('health', 0)
    end
end