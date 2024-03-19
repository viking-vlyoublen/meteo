local cartridge = require('cartridge')

local storage = require('app.src.storage')

local function init(opts)
    rawset(_G, "meteo_add", storage.meteo_add )
    rawset(_G, "meteo_lookup", storage.meteo_lookup )

    if opts.is_master then
        local meteo = box.schema.space.create('meteo', { if_not_exists = true })
        meteo:format({
            {'id', 'unsigned'},
            {'bucket_id', 'unsigned'},
            {'time', 'datetime'},
            {'temperature_2m', 'number'},
            {'wind_speed_10m', 'number'}
        })
        meteo:create_index('id', {parts = {'id'}, if_not_exists = true })
        meteo:create_index('bucket_id', {parts = {'bucket_id'}, unique = false, if_not_exists = true })

        box.schema.func.create('meteo_add', { if_not_exists = true })
        box.schema.role.grant('public', 'execute', 'function', 'meteo_add', { if_not_exists = true })
        box.schema.func.create('meteo_lookup', { if_not_exists = true })
        box.schema.role.grant('public', 'execute', 'function', 'meteo_lookup', { if_not_exists = true })
    end

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
    role_name = 'app.roles.cache',
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    dependencies = {'cartridge.roles.vshard-storage'}
}
