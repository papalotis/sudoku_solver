local Node = {}

function Node:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Node:draw (originX, originY, pixelWidth, sudokuWidth)

    local w = pixelWidth/sudokuWidth
    local xx = originX + (self.x - 1) * w
    local yy = originY + (self.y - 1) * w
    local rectX = xx
    local rectY = yy
    --draw rectangle
    love.graphics.rectangle("line", rectY, rectX, w, w)
    --draw value
    if (self.value ~= nil) then
        local offsetX = -5 * 360 / love.graphics.getWidth()
        local offsetY = -4 * 540 / love.graphics.getHeight()
        local scale = 2 * love.graphics.getWidth()/360
        love.graphics.print(self.value, yy, xx, 0, scale, scale, offsetX, offsetY)
        -- love.graphics.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
    end

end

function Node:create(x, y, value)
    local n = self:new()
    n.edges = {}
    n.value = value
    n.x = x
    n.y = y
    n.box = n:boxOrigin()
    n.prev = nil
    n.pencilmarks = {}
    n.fixed = 0
    n.pos = 0
    return n
end

function Node:boxOrigin(w) --returns a "hash" that represents each box uniquely
    -- body...
    w = w or 9
    local div = w/3
    local xx = math.floor(self.x/div) * div
    local yy = math.floor(self.y/div) * div

    if (self.x % div == 0) then xx = xx - div end
    if (self.y % div == 0) then yy = yy - div end



    return math.pow(2, xx + yy) + xx
end

function Node:addEdge(endNode) --adds an edge between this node and endNode
    -- body...
    self.edges[#self.edges + 1] = Edge:create(endNode)
end

function Node:getEdge(endNode) --return the edge that connects to nodes
    --if they aren't connected nil is returned
    -- body...
    for k,e in pairs(self.edges) do
        if (e.endnode == endNode) then
            do return e end
        end
    end
    return nil
end

function Node:equals(other) --returns true if two nodes are equal
    -- body...
    return self.x == other.x and self.y == other.y
end

function Node:getAdjacentNodes() --returns a list of all the nodes that this node
    --dominates
	local adjNodes = {}

	for _,e in pairs(self.edges) do
		adjNodes[#adjNodes + 1] = e.endnode;
    end

	return adjNodes;
end

function Node:hasNeighborWithSameValue() --returns true if this node has the same
    --value with one of its neighbors
    -- body...
    if (self.value == nil) then do return false end end
    local neighbors = self:getAdjacentNodes()
    for k,n in pairs(neighbors) do
        if (self.value == n.value) then
            do return true end
        end
    end
    return false
end

function Node:showCoor()
    -- body...
    local str = ""
    str = str .. tostring(self.x) .. "," .. tostring(self.y)
    love.window.showMessageBox("", str)
end


function Node:hasEdgeTo(endNode) --returns true if this node and endNode are
    --connected, otherwise false
    -- body...
    return self:getEdge(endNode) ~= nil

end

function findInList(list, val)
    -- body...
    local i = 1
    for k,v in pairs(list) do
        if (v == val) then
            do return i end
        end
        i = i + 1
    end

    return -1
end

function Node:findHiddenValue()
    -- body...
    local neighbors = self:getAdjacentNodes()
    local pencilmarksCopy = cloneList(self.pencilmarks)
    --row
    for k,n in pairs(neighbors) do
        if (n.x == self.x and self.y ~= n.y and n.value == nil) then
            for k,v in pairs(n.pencilmarks) do
                pencilmarksCopy = removeValueFromList(pencilmarksCopy, v)
            end
        end
    end
    -- showList(pencilmarksCopy)
    if (#pencilmarksCopy == 1) then self.pencilmarks = {pencilmarksCopy[1]}
        -- self:showCoor()

    else

        pencilmarksCopy = cloneList(self.pencilmarks)
        --column
        for k,n in pairs(neighbors) do
            if (n.y == self.y and self.x ~= n.x and n.value == nil) then
                for k,v in pairs(n.pencilmarks) do
                    pencilmarksCopy = removeValueFromList(pencilmarksCopy, v)
                end
            end
        end
        -- showList(pencilmarksCopy)
        if (#pencilmarksCopy == 1) then self.pencilmarks = {pencilmarksCopy[1]}
        else
            pencilmarksCopy = cloneList(self.pencilmarks)
            --box
            for k,n in pairs(neighbors) do
                if (n.box == self.box and not(self:equals(n)) and n.value == nil) then
                    for k,v in pairs(n.pencilmarks) do
                        pencilmarksCopy = removeValueFromList(pencilmarksCopy, v)
                    end
                end
            end
            -- showList(pencilmarksCopy)
            if (#pencilmarksCopy == 1) then self.pencilmarks = {pencilmarksCopy[1]} end
        end
    end


end

function Node:getNodesNextTo()
    -- body...
    local nodes = {}
    local neighbors = self:getAdjacentNodes()
    for k,n in pairs(neighbors) do
        if (math.abs(self.x - n.x) <= 1 and math.abs(self.y - n.y) <= 1 and (n.x == self.x or n.y == self.y)) then
            nodes[#nodes + 1] = n
        end
        if (#nodes >= 4) then break end
    end

    return nodes
end

function Node:fillPointingPair(row, column, box)
    -- body...
    local neighbors = self:getAdjacentNodes()
    local nextTo = self:getNodesNextTo()
    for k,n in pairs(nextTo) do --for each neighboring node
        -- if (n.box == self.box) then --if it is in the same box
        --     local atrr = "x"
        --     if (n.y == self.y) then atrr = "y"
        --     local common = commonItemsInLists(self.pencilmarks, n.pencilmarks)
        --     for k,v in pairs(common) do
        --         for k,node in pairs(box) do --for each node in the same box
        --             if (node ~= n and node ~= self) then
        --                 if (findInList(node.pencilmarks, v) ~= -1) then
        --                     for k, no in pairs(neighbors) do
        --                         if (no ~= n) then
        --                             removeValueFromList(no.pencilmarks, v)
        --                         end
        --                     end
        --                 end
        --             end
        --         end
        --     end
        -- end
    end
end


function Node:fillHiddenPairs(atrr, w)
    -- body...
    w = w or 9
    if (#self.pencilmarks > 1) then
        local list = nil
        if (atrr == "x") then list = self.rowNodes
        elseif (atrr == "y") then list = self.columnNodes
        elseif (atrr == "box") then list = self.boxNodes end

        local nodesWithSamePencilmarks = {self}
        local otherNodes = {}
        local seenNodes = 1
        for k,n in pairs(list) do
            if (n.value == nil) then
                seenNodes = seenNodes + 1
                if (listIsSublist(n.pencilmarks, self.pencilmarks)) then
                    nodesWithSamePencilmarks[#nodesWithSamePencilmarks + 1] = n
                else
                    otherNodes[#otherNodes + 1] = n
                end

                -- if (#nodesWithSamePencilmarks > #self.pencilmarks) then do return false end end
            end
            -- if (seenNodes >= w) then break end

        end
        if (#nodesWithSamePencilmarks == #self.pencilmarks and #nodesWithSamePencilmarks ~= 1) then
            for k,n in pairs(otherNodes) do
                if (n.value == nil) then
                    for k,v in pairs(self.pencilmarks) do
                        n.pencilmarks = removeValueFromList(n.pencilmarks, v)
                        -- print(string.format("Removed %.0f from %.0f, %.0f", v, n.x, n.y))
                    end
                end
            end
        end
    end
end


function Node:getNeighborsWithSameAtrr(atrr)
    -- body...
    local nodes = {}
    local neighbors = self:getAdjacentNodes()
    for k,n in pairs(neighbors) do
        if (n[atrr] == self[atrr]) then
            nodes[#nodes + 1] = n
        end
    end
    return nodes
end

function Node:initCollections()
    -- body...
    self.rowNodes = self:getNeighborsWithSameAtrr("x")
    self.columnNodes = self:getNeighborsWithSameAtrr("y")
    self.boxNodes = self:getNeighborsWithSameAtrr("box")
end


function Node:findNextCandidate(w)
    -- body..
    w = w or 9
    if (self.value == nil) then self.value = 1
    else self.value = self.value + 1 end

    while(true) do
        if (self.value > w) then break end
        if (findInList(self.pencilmarks,self.value) ~= -1) then
            break
        end
        self.value = self.value + 1
    end
end

function Node:fillPencilmarks(w)
    -- body...
    w = w or 9
    local cantBe = {}
    local neighbors = self:getAdjacentNodes()
    for k,n in pairs(neighbors) do
        local val = n.value
        if (findInList(cantBe, val) == -1) then
            cantBe[#cantBe + 1] = val
        end
    end
    self.pencilmarks = {}
    for i = 1, w do
        if (findInList(cantBe, i) == -1) then
            self.pencilmarks[#self.pencilmarks + 1] = i
        end
    end
end

return Node
