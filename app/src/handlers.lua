local cartridge = require('cartridge')
local json = require('json')
local vshard = require('vshard')
local log = require('log')

local function handle()

    return {body = 'Hello'}
end

local function get_meteo(req)
    local meteo_id = req:stash('id')

    local bucket_id = vshard.router.bucket_id(meteo_id)
    local res = vshard.router.call(
        bucket_id, { mode = 'read', prefer_replica=true }, 'meteo_lookup', { tonumber(meteo_id) }
    )

    return { body = json.encode(res), status = 200 }
end

local function put_meteo(req)
    local meteo = req:json()

    local bucket_id = vshard.router.bucket_id(meteo.id)
    meteo.bucket_id = bucket_id

    local res = vshard.router.call(
        bucket_id, 'write', 'meteo_add', { meteo }, {}
    )

    return { body = json.encode(res), status = 200 }
end

local function cache(req)
    local params = req:json()
    local lat = params.lat
    local lng = params.lng
    local url = string.format("https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current=temperature_2m,wind_speed_10m", lat, lng)

    local http_client = require('http.client').new()
    local res = http_client:request('GET', url)

    
    return { body = json.encode(res), status = 200 }
end

return {
    handle = handle,
    get_meteo = get_meteo,
    put_meteo = put_meteo,
    cache = cache
}