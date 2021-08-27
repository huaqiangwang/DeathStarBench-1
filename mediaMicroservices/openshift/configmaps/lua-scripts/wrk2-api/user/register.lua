local _M = {}

local function _StrIsEmpty(s)
  return s == nil or s == ''
end

function _M.RegisterUser()
  local GenericObjectPool = require "GenericObjectPool"
  local UserServiceClient = require 'media_service_UserService'
  local ngx = ngx

  local req_id = tonumber(string.sub(ngx.var.request_id, 0, 15), 16)
  local carrier = {}

  ngx.req.read_body()
  local post = ngx.req.get_post_args()

  if (_StrIsEmpty(post.first_name) or _StrIsEmpty(post.last_name) or
      _StrIsEmpty(post.username) or _StrIsEmpty(post.password)) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("Incomplete arguments")
    ngx.log(ngx.ERR, "Incomplete arguments")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  local client = GenericObjectPool:connection(UserServiceClient, "user-service.media-microsvc.svc.cluster.local", 9090)

  client:RegisterUser(req_id, post.first_name, post.last_name,
      post.username, post.password, carrier)
  GenericObjectPool:returnConnection(client)

end

return _M