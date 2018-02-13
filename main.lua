Sudoku = require "Sudoku"
Graph = require "Graph"
Node = require "Node"
Edge = require "Edge"
require "ListFunctions"

local sud, before, after, file
file = arg[1] or "inputSudoku.txt"
sud = Sudoku:create(9)
sud:readFromFile(file)
sud:print()

local times = 1
local avg = 0
for i=1,times do
    old = sud:clone()
    before = os.clock()
    sud:solve()
    after = os.clock()
    avg = avg + (after - before)
    if (i < times) then
        sud = old
    end
end

avg = avg / times
sud:print()
print(string.format("Solved in %.2f seconds", avg))
