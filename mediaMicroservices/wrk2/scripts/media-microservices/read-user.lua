require "socket"
time = socket.gettime()*1000
math.randomseed(time)
math.random(); math.random(); math.random()

request = function()
    local user_index = math.random(1000)
    local username = "username_" .. tostring(user_index)

    local path = "http://127.0.0.1:8080/wrk2-api/user/get"
    local method = "POST"
    local headers = {}
    local body = "username=" .. username
    headers["Content-Type"] = "application/x-www-form-urlencoded"

    return wrk.format(method, path, headers, body)
end