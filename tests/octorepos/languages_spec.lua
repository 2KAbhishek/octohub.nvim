local languages = require('octorepos.languages')
local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

describe('language_to_filetype', function()
    it('works with known languages', function()
        assert(languages.language_to_filetype('Python') == 'py', 'language_to_filetype function with param = Python')
        assert(
            languages.language_to_filetype('JavaScript') == 'js',
            'language_to_filetype function with param = JavaScript'
        )
        assert(
            languages.language_to_filetype('Markdown') == 'md',
            'language_to_filetype function with param = Markdown'
        )
    end)

    it('works with unknown language', function()
        assert(
            languages.language_to_filetype('NonExistentLanguage') == 'nonexistentlanguage',
            'language_to_filetype function with param = NonExistentLanguage'
        )
    end)

    it('works with nil language', function()
        assert(languages.language_to_filetype(vim.NIL) == 'md', 'language_to_filetype function with param = nil')
    end)
end)
