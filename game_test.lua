ao = require('.local_libs.mock_ao')
Handlers = require('.local_libs.mock_handlers')
bint = require('.local_libs.bint')(256)

local game = require('.game')


-- debug call
local From = "123"
local Msg = {
    From = From
}
game.Play(Msg)
game.Energy(Msg)

local exit_msg = {
    From = From,
    Tags = {
        Score = "100",
    }
}
game.Exit(exit_msg)