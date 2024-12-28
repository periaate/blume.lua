local M = {}

-- all: Returns true if every arguments satisfies the predicate.
function M.every(fn)
	return function(args)
		for _, arg in ipairs(args) do
			if not fn(arg) then return false end
		end
		return true
	end
end

-- any: Returns true if any argument satisfies the predicate.
function M.any(fn)
	return function(args)
		for _, arg in ipairs(args) do
			if fn(arg) then return true end
		end
		return false
	end
end

-- first: Returns the first value that satisfies the predicate.
function M.first(fn)
	return function(args)
		for _, arg in ipairs(args) do
			if fn(arg) then return arg end
		end
		return nil
	end
end

-- filter: Returns a list of values that satisfy the predicate.
function M.filter(fn)
	return function(args)
		local res = {}
		for _, arg in ipairs(args) do
			if fn(arg) then table.insert(res, arg) end
		end
		return res
	end
end

-- hasAny: Checks if a string contains any of the given substrings.
function M.hasAny(...)
    local substrings = { ... }
    return function(str)
        for _, substring in ipairs(substrings) do
            if string.find(str, substring, 1, true) then
                return true
            end
        end
        return false
    end
end

-- hasEvery: Checks if a string contains any of the given substrings.
function M.hasEvery(...)
    local substrings = { ... }
    return function(str)
        for _, substring in ipairs(substrings) do
            if not string.find(str, substring, 1, true) then return false end
        end
		return true
    end
end

-- hasPrefix: Checks if a string has any of the given prefixes.
function M.hasPrefix(...)
    local prefixes = { ... }
    return function(str)
        for _, prefix in ipairs(prefixes) do
            if string.sub(str, 1, #prefix) == prefix then return true end
        end
        return false
    end
end

-- hasSuffix: Checks if a string has any of the given suffixes.
function M.hasSuffix(...)
    local suffixes = { ... }
    return function(str)
        for _, suffix in ipairs(suffixes) do
            if string.sub(str, -#suffix) == suffix then return true end
        end
        return false
    end
end

-- replacePrefix: Replaces prefixes based on pattern pairs.
function M.replacePrefix(...)
    local pats = { ... }
    return function(str)
        if #pats % 2 ~= 0 then return str end
        for i = 1, #pats, 2 do
            local prefix = pats[i]
            if #prefix <= #str and string.sub(str, 1, #prefix) == prefix then
                return pats[i + 1] .. string.sub(str, #prefix + 1)
            end
        end
        return str
    end
end

-- replaceSuffix: Replaces suffixes based on pattern pairs.
function M.replaceSuffix(...)
    local pats = { ... }
    return function(str)
        if #pats % 2 ~= 0 then return str end
        for i = 1, #pats, 2 do
            local suffix = pats[i]
            if #suffix <= #str and string.sub(str, -#suffix) == suffix then
                return string.sub(str, 1, -#suffix - 1) .. pats[i + 1]
            end
        end
        return str
    end
end

-- isAny: Checks if a value is equal to any of the given values.
function M.isAny(...)
    local values = { ... }
    return function(input)
        for _, value in ipairs(values) do
			if value == input then return true end
        end
		return false
    end
end

-- isNone: Checks if a value isn't equal to any of the given values.
function M.isNone(...)
    local values = { ... }
    return function(input)
        for _, value in ipairs(values) do
			if value ~= input then return false end
        end
		return true
    end
end

return M
