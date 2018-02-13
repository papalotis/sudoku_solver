local Edge = {}

function Edge:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Edge:create(endNode)
    local e = self:new()
    e.endnode = endNode

    return e
end

return Edge
