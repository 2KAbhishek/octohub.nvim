return {
    setup = function (opts)
        require('octohub.config').setup(opts)
        require('octohub.setup_cmd').setup()
    end
}
