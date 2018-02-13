function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local directory = "./"
--get all the files in the directory where the tests are
local file_table = scandir(directory)
local start = os.date()
print(start)
for i,fname in ipairs(file_table) do


    --if this is a lua file and it shouldn't be ignored
    if (string.sub(fname, -3) == "txt") then

        --run the test and strore the result (exit status)
        --this can vary from machine to machine
        --on the server it is the first result, on my machine it is the third
        local res_server, _, res_mylaptop = os.execute("lua main.lua " ..  directory .. fname)
    end
end

local dur = os.clock() - start
print(string.format("%.2f", dur))
