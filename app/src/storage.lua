local log = require('log')

local function meteo_add(meteo)
    local meteo_tuple = box.space.meteo:frommap(meteo)
    box.space.meteo:insert(meteo_tuple)
    return meteo
end

local function meteo_lookup(meteo_id)
    local meteo_tuple = box.space.meteo:get(meteo_id)
    if meteo_tuple == nil then
        return nil
    end

    local meteo = meteo_tuple:tomap({ names_only = true })

    return meteo
end

return {
    meteo_add = meteo_add,
    meteo_lookup = meteo_lookup
}