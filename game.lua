if not ao then ao = require('ao') end

Name = "Watermelon game test logic"
Desc = "The Watermelon test game logic"

---@class Player
Player = {}

function Player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.level = 0
    o.energy = 10
    o.score = 0
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

---@class game logic
local game = {}

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
    if player.energy > 0 then
        player.energy = player.energy - 1
    else
        ao.send({
            Target = msg.From,
            Data = "Failed",
            Energy = tostring(player.energy)
        })
        return
    end

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

-- registry handlers
Handlers.add('play', Handlers.utils.hasMatchingTag('Action', 'Play'), game.Play)
Handlers.add('energy', Handlers.utils.hasMatchingTag('Action', 'Energy'), game.Energy)

return game