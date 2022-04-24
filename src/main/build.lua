
local cjson = require "cjson"
local ck = require "resty.cookie"
local ck_obj = ck:new()
local ck_name = "X-Trace"
local ck_domain = "localhost"
local ck_path = "/"
local ck_expires = ngx.time() + 3600
local ck_max_age = 3600
local ck_secure = false
local ck_httponly = true


local function make_cookie(trace_id)
    local cookie = {
        key = ck_name,
        value = trace_id,
        path = ck_path,
        domain = ck_domain,
        expires = ck_expires,
        max_age = ck_max_age,
        secure = ck_secure,
        httponly = ck_httponly
    }
    return cookie
end


local function make_cookie_str(trace_id)
    local cookie = make_cookie(trace_id)
    local cookie_str = ck_obj:new_cookie(cookie)
    return cookie_str
end


local function get_cookie()
    local cookie_str = ngx.var.http_cookie
    local cookie_tbl = ck_obj:parse(cookie_str)
    local trace_id = cookie_tbl[ck_name]
    return trace_id
end


local function set_cookie(trace_id)
    local cookie_str = make_cookie_str(trace_id)
    ngx.header["Set-Cookie"] = cookie_str
end


local function get_trace_id()
    local trace_id = get_cookie()
    if trace_id == nil then
        trace_id = ngx.md5(ngx.time())
        set_cookie(trace_id)
    end
    return trace_id
end

for k, v in pairs(get_trace_id()) do
    ngx.say(k, ":", v)
end



local function grabcookie()
    local httponly = true
    if httponly then
        local cookie_str = ngx.var.http_cookie
        local cookie_tbl = ck_obj:parse(cookie_str)
        local trace_id = cookie_tbl[ck_name]
        return trace_id
    end
    for _,v in ipairs(ngx.req.get_headers()) do
        if v.key == "Cookie" then
            local cookie_str = v.value
            local cookie_tbl = ck_obj:parse(cookie_str)
            local trace_id = cookie_tbl[ck_name]
            return trace_id
        end
    end
    if trace_id == nil then
        trace_id = ngx.md5(ngx.time())
        set_cookie(trace_id)
    end
    return trace_id
end



make_cookie()
make_cookie_str()
get_cookie()
set_cookie()
get_trace_id()
grabcookie()


