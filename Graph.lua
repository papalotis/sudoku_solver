local Graph = {}

function Graph:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Graph:create(w) --creates a new empty graph
    local g = self:new()
    g.nodes = {}
    g.w = w or 9
    return g
end

function Graph:addNode (x,y) --adds a node to the graph
    -- body...
    local newNode = Node:create(x,y)
    self.nodes[#self.nodes + 1] = newNode
    return newNode
end

function Graph:getNode(x, y) --returns the node with a specific x and y
    --if it doesn't exist nil is returned
    -- body...
    for k,n in pairs(self.nodes) do
        if (n.x == x and n.y == y) then
            do return n end
        end
    end

    return nil
end

function Graph:addEdge (startNode, endNode) --connects to nodes if they aren't
    --already connected
    -- body...
    if (startNode:getEdge(endNode) == nil) then
        startNode:addEdge(endNode)
    end
end

function Graph:getAdjacentNodes(startnode) --returns a list of all nodes
    --that startNode dominates
	return startnode.getAdjacentNodes()
end

function Graph:isConnected(startnode, endNode) --returns true if startNode and
    --endNode are connected, otherwise false
    return startNode:hasEdgeTo(endNode) ~= nil
end

function Graph:connectNodeSudoku(node) --connects a node to all the other nodes
    --that affect it according to sudoku rules
    -- body...
    local n = nil
    local i, j = nil, nil
    for k,n in pairs(self.nodes) do
        if (node.x ~= n.x or node.y ~= n.y) then
            if (node.x == n.x or node.y == n.y or node.box == n.box) then
                self:addEdge(node,n)
            end
        end
    end
end

function Graph:initSudoku() --initilizes a graph so that the nodes represent an
    --empty sudoku grid
    -- body...
    --createNodes
    for i = 1, self.w do
        for j = 1, self.w do
            self:addNode(i,j)
        end
    end
    --connect nodes
    for k,node in pairs(self.nodes) do
        self:connectNodeSudoku(node)
    end

    for k,node in pairs(self.nodes) do
        node:initCollections()
    end
end

return Graph
