local _M = {}

local dump
dump = function (o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function _M.test()


  local carrier = {}
  ngx.say("<p>hello, world</p>")
  ngx.say(dump(carrier))
end

return _M
