local cartridge = require('cartridge')

local handlers = require('app.src.handlers')

local function init(opts) 

    local httpd = assert(cartridge.service_get('httpd'), "Failed to get httpd service")
    httpd:route({method = 'GET', path = '/handler'}, handlers.handle)
    httpd:route({method = 'POST', path = '/meteo'}, handlers.cache)

    return true
end

local function stop()
    return true
end

local function validate_config(conf_new, conf_old) -- luacheck: no unused args
    return true
end

local function apply_config(conf, opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    return true
end

return {
    role_name = 'app.roles.router',
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    dependencies = {'cartridge.roles.vshard-router'}
}
