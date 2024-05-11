if not ao then ao = require('ao') end
if not bint then bint = require('.bint')(256) end

Name = "Watermelon game test logic"
Desc = "The Watermelon test game logic"
TokenId = "B0eqx0sElSUYLGIIZLgH9Zy1r8ye6osCZtVwKRCyB2I"

---@class game logic
game = game or {}

---@class Player
Player = {}

function Player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.level = 0
    o.energy = 10
    o.score = 0
    o.timeline = {} -- Record player operation sequence
    o.state = "idle" -- idle or playing
    return o
end

function Player:AddEnergy(num)
    self.energy = self.energy + num
    if self.energy > 10 then
        self.energy = 10
    end
end

---@map players
Players = Players or {}


-- function list
--[[
    Play a game, need 1 Engry pre.

    - From: string , player address
]]--
game.Play = function(msg)
    if not Players[msg.From] then
        Players[msg.From] = Player:new(nil)
    end
    local player = Players[msg.From]

    if player.energy <= 0 then
        ao.send({
            Target = msg.From,
            Data = "Failed",
            Error = "Not enough energy",
            Energy = tostring(player.energy)
        })
        return
    end

    player.energy = player.energy - 1
    player.state = "playing"
    -- clear timeline
    player.timeline = {}

    ao.send({
        Target = msg.From,
        Data = "success",
        Energy = tostring(player.energy)
    })
end

--[[
    Get player's Energy

    - From: string , player address
]]--
game.Energy = function(msg)
    if not Players[msg.From] then
        Players[msg.From] = Player:new(nil)
    end

    ao.send({
        Target = msg.From,
        Data = tostring(Players[msg.From].energy)
    })
end

--[[
    Exit game and get score

    - From: string, player address
    - score: string, score of this game
]]--
game.Exit = function(msg)
    assert(type(msg.Tags.Score) == 'string', 'Score is required!')
    assert(bint(0) <= bint(msg.Tags.Score), 'Score must be greater than 0')
    if not Players[msg.From] then
        Players[msg.From] = Player:new(nil)
    end

    local player = Players[msg.From]
    if player.state ~= "playing" then
        ao.send({
            Target = msg.From,
            Action = 'Verify-Error',
            Data = "Failed",
            Error = "Player is not playing the game"
        })
        return
    end

    player.state = "idle"

    local valid = game.Verify(msg.From, bint(msg.Tags.Score))
    if valid then
        local tokens = game.CalculateToken(bint(msg.Tags.Score))
        game.Mint(msg.From, tokens)
        ao.send({
            Target = msg.From,
            Tokens = tostring(tokens),
            Data = "success",
        })
    else
        ao.send({
            Target = msg.From,
            Action = 'Verify-Error',
            Data = "Failed",
            Error = "Verify failed"
        })
    end
end

--[[
     verify 

     -- player_addr: string
     -- score: int 
     -- return: bool
]]--
game.Verify = function(player_addr, score)
    -- TODO: verify player's timeline
    return true
end

--[[
     Calculate how many tokens can get based on the score

     -- score: int
     -- return: int, number of the tokens
]]--
game.CalculateToken = function (score)
    return 10
end

--[[
     Mint tokens to the player

     -- score: int
     -- return: int, number of the tokens
]]--
game.Mint = function (player_addr,tokens)
    ao.send({
        Target = TokenId,
        Action = "Mint",
        To = player_addr,
        Quantity = tostring(tokens)
    })
end

-- registry handlers
Handlers.add('play', Handlers.utils.hasMatchingTag('Action', 'Play'), game.Play)
Handlers.add('energy', Handlers.utils.hasMatchingTag('Action', 'Energy'), game.Energy)
Handlers.add('exit', Handlers.utils.hasMatchingTag('Action', 'Exit'), game.Exit)

return game