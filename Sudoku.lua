local Sudoku = {}

function Sudoku:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Sudoku:create(w)
    local s = Sudoku:new(nil)
    s.width = w or 9
    s.graph = Graph:create(s.width)
    s.graph:initSudoku()

    return s
end

function Sudoku:getCell(x, y) --returns the cell with a specific x,y
    -- body...
    return self.graph:getNode(x,y)
end

function Sudoku:clone() --returns an exact copy of the sudoku
    -- body...
    local s = Sudoku:create(self.width)
    for i = 1, self.width do
        for j = 1, self.width do
            local val = self:getCell(i,j).value
            s:setCell(i, j, val)
        end
    end
    return s

end

function Sudoku:setCell (x, y, val) --set the value of a cell with a specific x,y
    -- and return that cell
    local n = self:getCell(x,y)
    n.value = val
    return n
end



function Sudoku:solve() --solves a Sudoku in a bruteforce way (ie dumb)
    local timer = 0
    local notDone = true
    local start = self:findNextEmpty()
    local cur = start
    local next = nil
    self:doPencilmarks()
    local r = true
    while (notDone) do
        if (cur ~= nil) then
            if (cur.fixed ~= 2) then
                cur:findNextCandidate()
            end
            if (self:isCompleted()) then
                notDone = false

            --if we tried all the numbers go back to the previous cell
            elseif (cur.value > self.width) then
                cur.value = nil
                cur = cur.prev
            elseif (self:isValidSudoku()) then
                next = self:findNextEmpty()
                next.prev = cur
                next.pos = cur.pos + 1
                cur = next

                self:eliminatePencilmarks(false)
            end
        else
            r = false
            notDone = false
        end
        timer = timer + 1
    end

    return timer
end

function Sudoku:eliminatePencilmarks(doHiddenPencilmarks)
    -- body...
    self:fillPencilmarks()
    self:fillHiddenCells()
    if (doHiddenPencilmarks) then --we only want to do this when we are not guessing
                                  --because this is a very resource heavy function
        self:fillHiddenPairs()
    end
end

function Sudoku:doPencilmarks ()
    -- body...
    local oldS = self:clone()
    while (true) do
        self:eliminatePencilmarks(true)
        self:fillObvious()
        if (self:numberOfEmpty() == oldS:numberOfEmpty()) then break
        else oldS = self:clone() end
    end
end

function Sudoku:isValidSudoku() --returns true if the Sudoku is valid
    -- body...
    for k,n in pairs(self.graph.nodes) do
        if (n:hasNeighborWithSameValue()) then
            do return false end
        end
    end
    return true
end

function Sudoku:findNextEmpty() --returns the cell that is empty and has the
    --least amount of pencilmarks
    -- body...
    local smallest = nil
    for k,n in pairs(self.graph.nodes) do
        if (smallest == nil) then
            if (n.value == nil) then
                smallest = n
            end
        else
            if (n.value == nil and #n.pencilmarks < #smallest.pencilmarks) then
                smallest = n
            end
        end
    end
    return smallest
end

function Sudoku:readFromTable(table) --reads and sets the values the sudoku from table
    -- body...
    for i = 1, self.width do
        for j = 1, self.width do
            local val = table[i][j]
            local n = self:setCell(i, j ,val)
            if (val ~= nil) then
                n.fixed = 1
            end
        end
    end
end

function Sudoku:readFromFile(file)
    -- body...
    io.input(file)

    local s = {}
    local i = 1
    for str in io.lines(file) do
        s[i] = {}
        for j = 1, str:len() do
            s[i][j] = tonumber(str:sub(j,j))
        end
        i = i + 1
    end

    self:readFromTable(s)
end



function Sudoku:print()
    -- body...
    local str = ""
    for i = 1, self.width do
        for j = 1, self.width do
            local n = self:getCell(i,j)
            local s = tostring(n.value)
            if (n.value == nil) then s = " " end
            str = (str .. " ") .. s
        end
        print(str)
        str = ""
    end

end

function Sudoku:numberOfEmpty()
    -- body...
    local k = 0
    for _,n in pairs(self.graph.nodes) do
        if (n.value == nil) then
            k = k + 1
        end
    end
    return k
end

function Sudoku:draw(originX,originY,pixelWidth, colour)
    -- body...
    originX = originX or 0
    originY = originY or 0
    pixelWidth = pixelWidth or math.min(love.graphics.getHeight(), love.graphics.getWidth())
    colour = colour or {0,0,0,0}

    local thinLine = 1
    local thickLine = 5
    for k,n in pairs(self.graph.nodes) do
        love.graphics.setLineWidth(thinLine)
        n:draw(originX, originY, pixelWidth, self.width)
        local rectX = originX + (n.x - 1) * pixelWidth/(self.width)
        local rectY = originX + (n.y - 1) * pixelWidth/(self.width)
        if (n.x % (self.width/3) == 1 and n.y % (self.width/3) == 1) then
            love.graphics.setLineWidth(thickLine)
            love.graphics.rectangle("line", rectY, rectX, pixelWidth/3, pixelWidth/3)
        end
    end
end



function Sudoku:isCompleted() --returns true if there are no empty cells
    -- body...
    return self:findNextEmpty() == nil and self:isValidSudoku()
end

function Sudoku:equals(other) --returns true if two Sudokus have the same values
    --for all cells
    -- body...
    if (self.width ~= other.width) then do return false end end

    for i = 1, self.width do
        for j = 1, self.width do
            local n1 = self:getCell(i,j)
            local n2 = other:getCell(i,j)
            if (n1.value ~= n2.value) then
                do return false end
            end
        end
    end
    return true
end


function Sudoku:getColumn(col)
    -- body...
    local nodes = {}
    for k,n in pairs(self.graph.nodes) do
        if (n.x == col) then
            nodes[#nodes + 1] = n
        end
        if (#nodes >= self.width) then
            break
        end
    end



    return nodes
end

function Sudoku:getRow(row)
    -- body...
    local nodes = {}
    for k,n in pairs(self.graph.nodes) do
        if (n.y == row) then
            nodes[#nodes + 1] = n
        end
        if (#nodes == self.width) then
            break
        end
    end


    return nodes
end

function Sudoku:getBox(x,y)
    -- body...
    local nodes = {}
    local n = Node:create(x,y)
    local orig = n.box
    n = nil
    for k,n in pairs(self.graph.nodes) do
        if (n.box == orig) then
            nodes[#nodes + 1] = n
        end
        if (#nodes == self.width) then
            break
        end
    end

    return nodes
end


function Sudoku:fillPointingPair()
    -- body...
    for k,n in pairs(self.graph.nodes) do
        n:fillPointingPair(self:getBox(n.x, n))
    end
end


function Sudoku:fillHiddenCells(w)
    -- body...
    w = w or 9
    for k,n in pairs(self.graph.nodes) do
        if (n.value == nil) then
            n:findHiddenValue()
        end
    end

end



function Sudoku:fillPencilmarks()
    -- body...
    for k,n in pairs(self.graph.nodes) do
        if (n.value == nil) then
            n:fillPencilmarks()
        end
    end
end

function Sudoku:fillHiddenPairs()
    -- body...
    for k,n in pairs(self.graph.nodes) do
        if (n.value == nil and #n.pencilmarks > 1) then
            n:fillHiddenPairs("x")
            n:fillHiddenPairs("y")
            n:fillHiddenPairs("box")
        end
    end
end



function Sudoku:fillObvious()
    -- body...
    for k,n in pairs(self.graph.nodes) do
        if (#n.pencilmarks == 1) then
            n.value = n.pencilmarks[1]
            n.fixed = 2
        end
    end

end


return Sudoku
