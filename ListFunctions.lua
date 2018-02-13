function cloneList(list)
    -- body...
    local clone = {}
    for k,v in pairs(list) do
        clone[#clone + 1] = v
    end
    return clone
end


function removeValueFromList(list, val)
    -- body...
    local new = {}
    for k,v in pairs(list) do
        if (v ~= val) then
            new[#new + 1] = v
        end
    end
    return new
end

function listEquals(list1, list2)
    -- body...
    if (#list1 ~= #list2) then do return false end end
    for k,v in pairs(list1) do
        if (findInList(list2, v) == -1) then
            do return false end
        end
    end
    return true
end

function commonItemsInLists(list1, list2)
    -- body...
    local vals = {}
    for k,v in pairs(list1) do
        if (findInList(list2, v) ~= -1) then
            vals[#vals + 1] = v
        end
    end
    return vals
end

function listIsSublist(list1, list2) --all of the elements of list1 appear on list2
    -- body...
    -- if (listEquals(list1, list2)) then do return true end end
    if (#list1 > #list2) then do return false end end
    for k,v in pairs(list1) do
        if (findInList(list2, v) == -1) then
            do return false end
        end
    end
    return true
end
