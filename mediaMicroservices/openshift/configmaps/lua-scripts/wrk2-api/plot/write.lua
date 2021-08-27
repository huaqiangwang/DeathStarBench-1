local _M = {}

function _M.WritePlot()
  local GenericObjectPool = require "GenericObjectPool"
  local PlotServiceClient = require 'media_service_PlotService'
  local ngx = ngx
  local cjson = require("cjson")

  local req_id = tonumber(string.sub(ngx.var.request_id, 0, 15), 16)
  local carrier = {}

  ngx.req.read_body()
  local data = ngx.req.get_body_data()

  if not data then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("Empty body")
    ngx.log(ngx.ERR, "Empty body")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  local plot = cjson.decode(data)
  if (plot["plot_id"] == nil or plot["plot"] == nil) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("Incomplete arguments")
    ngx.log(ngx.ERR, "Incomplete arguments")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
  end

  local client = GenericObjectPool:connection(PlotServiceClient, "plot-service.media-microsvc.svc.cluster.local", 9090)
  client:WritePlot(req_id, plot["plot_id"], plot["plot"], carrier)
  GenericObjectPool:returnConnection(client)
end

return _M