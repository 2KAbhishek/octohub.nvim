return {
    setup = function(opts)
        require('octohub.config').setup(opts)
        require('octohub.commands').setup()
    end,
}
