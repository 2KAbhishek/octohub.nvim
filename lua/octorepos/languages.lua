local M = {}

M.language_to_filetype = function(language)
    local map = {
        ['C'] = 'c',
        ['C++'] = 'cpp',
        ['Java'] = 'java',
        ['Python'] = 'py',
        ['JavaScript'] = 'js',
        ['TypeScript'] = 'ts',
        ['Ruby'] = 'rb',
        ['Go'] = 'go',
        ['Rust'] = 'rs',
        ['Shell'] = 'sh',
        ['Lua'] = 'lua',
        ['HTML'] = 'html',
        ['CSS'] = 'css',
        ['PHP'] = 'php',
        ['Swift'] = 'swift',
        ['Kotlin'] = 'kt',
        ['Scala'] = 'scala',
        ['Groovy'] = 'groovy',
        ['Perl'] = 'perl',
        ['R'] = 'r',
        ['Julia'] = 'jl',
        ['Haskell'] = 'hs',
        ['Objective-C'] = 'm',
        ['C#'] = 'cs',
        ['F#'] = 'fs',
        ['Visual Basic .NET'] = 'vb',
        ['SQL'] = 'sql',
        ['MATLAB'] = 'm',
        ['Bash'] = 'sh',
        ['Powershell'] = 'ps1',
        ['Dart'] = 'dart',
        ['Clojure'] = 'clj',
        ['Elixir'] = 'ex',
        ['Erlang'] = 'erl',
    }

    local filetype = map[language]
    return filetype or 'md'
end

return M
