-- Module to help in getting players, own module because of it's size.

--local players = services.Players
local gmatch, match = string.gmatch, string.match
local split, sub, lower = string.split, string.sub, string.lower
local random = math.random
local remove = table.remove

local cases = {}

cases.all = function()
    return players:GetPlayers()
end

cases.others = function(speaker)
    local result = {}
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= speaker then
            result[#result + 1] = player
        end
    end
    return result
end

cases.me = function(speaker)
    return {speaker}
end

cases['#(%d+)'] = function(_, input, playersList)
    local result = {}
    for _ = 1, input do
        local count = #playersList
        if count == 0 then
            break
        end
        result[#result + 1] = remove(playersList, random(count))
    end
    return result
end

cases.random = function(_, _, playersList)
    return {playersList[random(#playersList)]}
end

cases['%%(.+)'] = function(_, input)
    local result = {}
    input = lower(input)
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        local team = player.Team
        if team and lower(sub(team.Name, 1, #input)) == input then
            result[#result + 1] = player
        end
    end
    return result
end

cases.allies = function(speaker)
    local result = {}
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player.Team == speaker.Team then
            result[#result + 1] = player
        end
    end
    return result
end

cases.enemies = function(speaker)
    local result = {}
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player.Team ~= speaker.Team then
            result[#result + 1] = player
        end
    end
    return result
end

cases.friends = function(speaker)
    local result = {}
    local id = speaker.UserId
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= speaker and player:IsFriendsWith(id) then
            result[#result + 1] = player
        end
    end
    return result
end

cases.nonfriends = function(speaker)
    local result = {}
    local id = speaker.UserId
    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= speaker and not player:IsFriendsWith(id) then
            result[#result + 1] = player
        end
    end
    return result
end

local getPlayers = function(query)
    local result = {}
    local playersList = players:GetPlayers()
    query = lower(query)
    for i = 1, #playersList do
        local player = playersList[i]
        if lower(sub(player.Name, 1, #query)) == query then
            result[#result + 1] = player
        end
    end
    return result
end

local getTokens = function(query)
    local tokens = {}
    for op, input in gmatch(query, '([+-])(.-)') do
        tokens[#tokens + 1] = {op, input}
    end
    return tokens
end

local include = function(tbl, matchTbl)
    local included = {}
    local set = {}
    for i = 1, #matchTbl do
        set[matchTbl[i]] = true
    end
    for i = 1, #tbl do
        local v = tbl[i]
        if set[v] then
            included[#included + 1] = v
        end
    end
    return included
end

local exclude = function(tbl, matchTbl)
    local excluded = {}
    local set = {}
    for i = 1, #matchTbl do
        set[matchTbl[i]] = true
    end
    for i = 1, #tbl do
        local v = tbl[i]
        if not set[v] then
            excluded[#excluded + 1] = v
        end
    end
    return excluded
end


return function(query, speaker, fallback)
    local result = {}
    local arguments = split(query, ',')
    for i = 1, #arguments do
        local argument = arguments[i]
        local playersList = players:GetPlayers()
        local beginning = sub(argument, 1, 1)
        if beginning ~= '+' and beginning ~= '-' then
            argument = '+'..argument
        end
        local tokens = getTokens(argument)
        for x = 1, #tokens do
            local token = tokens[x]
            local operator, name = token[1], token[2]
            if operator == '+' then
                local foundCase = false
                for case, fn in pairs(cases) do
                    local input = match(name, '^'..case..'$')
                    if input then
                        foundCase = true
                        playersList = include(playersList, fn(speaker, input, playersList))
                    end
                end
                if not foundCase then
                    playersList = include(playersList, getPlayers(name))
                end
            else
                local foundCase = false
                for case, fn in pairs(cases) do
                    local input = match(name, '^'..case..'$')
                    if input then
                        foundCase = true
                        playersList = exclude(playersList, fn(speaker, input, playersList))
                    end
                end
                if not foundCase then
                    playersList = exclude(playersList, getPlayers(name))
                end
            end
        end
        for x = 1, #playersList do
            result[#result + 1] = playersList[x]
        end
    end
    if fallback and #result == 0 then
        result[1] = speaker
    end
    return result
end