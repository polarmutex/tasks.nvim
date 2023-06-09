local tasks = require('tasks')
local stub = require('luassert.stub')
describe('Can call setup with default configs.', function()
    local notify_once = stub(vim, 'notify_once')
    local notify = stub(vim, 'notify')
    tasks.setup()
    it('Public API is available after setup.', function() assert(tasks.repl == nil) end)
    it('No notifications at startup.', function()
        assert.stub(notify_once).was_not_called()
        assert.stub(notify).was_not_called()
    end)
end)
