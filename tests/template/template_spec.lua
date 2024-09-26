local template = require('template')

describe('setup', function()
    it('works with default', function()
        assert(template.hello() == 'Hello World!', 'greet function with param = World!')
    end)

    it('works with custom var', function()
        template.setup({ name = 'Template' })
        assert(template.hello() == 'Hello Template', 'greet function with param = Template')
    end)
end)
