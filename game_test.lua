ao = require('.local_libs.mock_ao')
Handlers = require('.local_libs.mock_handlers')

local game = require('.game')

-- debug call
local Msg = {
    From = "123"
}
game.Play(Msg)
game.Energy(Msg)