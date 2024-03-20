local cartridge = require('cartridge')
local json = require('json')
local vshard = require('vshard')

local function handle()

    return {body = 'Hello'}
end

local function get_meteo(id)

    local bucket_id = vshard.router.bucket_id_strcrc32(id)
    local res = vshard.router.call(
        bucket_id, { mode = 'read', prefer_replica=true }, 'meteo_lookup', { id }
    )

    return res
end

local function put_meteo(meteo)

    local bucket_id = vshard.router.bucket_id_strcrc32(meteo.id)
    meteo.bucket_id = bucket_id

    local res = vshard.router.call(
        bucket_id, 'write', 'meteo_add', { meteo }, {}
    )

    return res
end

local function cache(req)
    local params = req:json()
    local lat = params.lat
    local lng = params.lng

    local id = lat .. lng
    
    local meteo = get_meteo(id)

    if meteo == nil then
        local url = string.format("https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current=temperature_2m,wind_speed_10m", lat, lng)

        local http_client = require('http.client').new()
        local res = http_client:request('GET', url)

        local res_body = json.decode(res.body)
        local current = res_body.current

        current.id = id

        local result = put_meteo(current)
        
        return { body = 'Created: '..json.encode(result), status = 200 }
    else 
        return { body = 'Cached: '..json.encode(meteo), status = 200 }
    end
    
end

return {
    handle = handle,
    get_meteo = get_meteo,
    put_meteo = put_meteo,
    cache = cache
}