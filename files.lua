function saveMaxScore(max)
    local data = max
    --data.whatever = "Nick"
    -- Save the table to the "savegame.txt" file:
    love.filesystem.write("resources/csv/hi.txt", data.maxScor)
end

function loadMaxScore()    
    --[[
    if not love.filesystem.exists("score.txt") then
        maxScor = 0
        saveMaxScore()
    end]]--
    -- Load the data table:
    local data = love.filesystem.read("resources/csv/hi.txt")()
    -- Copy the variables out of the table:
    maxScor = tonumber(data--[[.maxScor]])
    return maxScor
end