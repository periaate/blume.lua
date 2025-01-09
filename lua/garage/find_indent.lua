-- Function to count spaces and tabs in a given string
local function count_indentation(line)
	local spaces = 0
	local tabs = 0

	for i = 1, #line do
		local char = line:sub(i, i)
		if char == " " then
			spaces = spaces + 1
		elseif char == "\t" then
			tabs = tabs + 1
		else
			break
		end
	end

	return spaces, tabs
end

-- Function to process the lines of a text and find the most common indentation
local function find_most_common_indentation(text)
	local indentations = {}

	for line in text:gmatch("[^\r\n]+") do
		if line:find("^[ \t]+") and not line:find("^%s+$") then
			local spaces, tabs = count_indentation(line)
			local key = spaces .. "s_" .. tabs .. "t"

			if not indentations[key] then indentations[key] = 0 end

			indentations[key] = indentations[key] + 1
		end
	end

	local max_count = 0
	local most_common_key = nil

	for key, count in pairs(indentations) do
		if count > max_count then
			max_count = count
			most_common_key = key
		end
	end

	if most_common_key then
		local spaces, tabs = most_common_key:match("(%d+)s_(%d+)t")
		return tonumber(spaces), tonumber(tabs)
	else
		return nil, nil
	end
end


local function set_indentation_type()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local text = table.concat(lines, "\n")
	local spaces, tabs = find_most_common_indentation(text)
	if not spaces or not tabs or tabs == spaces then return end
	vim.o.expandtab = spaces > tabs
end

return {
	set_indent = set_indentation_type,
	setup = function()
		vim.api.nvim_create_autocmd("BufEnter", { callback = function()
			set_indentation_type()
		end})
	end
}

