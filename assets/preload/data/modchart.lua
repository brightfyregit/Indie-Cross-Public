function start (song)
	print("Song: " .. song .. " @ " .. bpm .. " donwscroll: " .. downscroll)
end


function update (elapsed)
    local currentBeat = (songPos / 1000)*(bpm/60)
        for i=0,7 do
        setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
        end
end