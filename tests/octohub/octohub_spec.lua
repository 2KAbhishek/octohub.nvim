local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

local octohub = require('octohub')

describe('octohub', function()
    describe('setup', function()
        it('checks if setup function exists', function()
            assert.is_not_nil(octohub.setup)
            assert.are.equals(type(octohub.setup), 'function')
        end)
    end)
end)
