local json = require('lib.json')
local bfr = require("lib.bfr")

local M = {}

local function clean(path)
	path = path or ""
	path = path:gsub("\\", "/")
	path = path:gsub("//+", "/")
	return path
end

local function tpath(path)
	path = path or ""
	path = path:gsub("\\", "")
	path = path:gsub("/", "")
	path = path:gsub(":", "")
	return path
end

function M.get_cwd() return vim.fn.getcwd() end
function M.set_cwd(path) vim.cmd('cd ' .. path) end

local last = nil

function M.get_filetype(bufnr)
	if bfr.is_valid(bufnr) then
		return vim.api.nvim_buf_get_option(bufnr, 'filetype')
	end
	return nil
end

-- Function to close all buffers without exiting Neovim
function M.close_all_buffers()
	local buffers = bfr.list_all()
	for _, buf in ipairs(buffers) do
		if M.not_term(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end

function M.not_term(bufnr)
	return M.get_filetype(bufnr) ~= "toggleterm"
end

function M.change_session(path)
	if not path then return end
	local cur = M.get_cwd()
	M.save_session()
	M.set_cwd(path)
	M.close_all_buffers()
	last = cur

	vim.cmd([[1TermExec cmd="cd ]] .. path .. [[" open=0]])
	if M.exists(path) then
		M.load_session()
		require("lib.fthooks").recheck()
	else
		require("oil").open()
	end
end

function M.last_session()
	if last then M.change_session(last) end
end

function write_file(filepath, content)
	local file, err = io.open(filepath, "w")
	if not file then
		-- error('Could not open file for writing: ' .. err)
		return
	end
	file:write(content)
	file:close()
end

function read_file(filepath)
	local file, err = io.open(filepath, "r")
	if not file then return end
	local content = file:read("*all")
	file:close()
	return content
end


local function get_buffers_and_cursors()
	local first = bfr.get_current()
	local fname = bfr.get_name(first)

	local result = { focus = clean(fname), files = {} }
	for _, buf in ipairs(bfr.list_loaded()) do
		local filepath = vim.api.nvim_buf_get_name(buf)
		if filepath ~= '' and M.not_term(buf) then
			bfr.set_current(buf)
			local cursor_position = bfr.get_cursor_position(buf)
			print("Row: " .. cursor_position.row .. " Col: " .. cursor_position.col)

			table.insert(result.files, {
				filepath = clean(filepath),
				cursor_position = cursor_position
			})
		end
	end

	bfr.set_current(first)
	return result
end

local function open_files_with_positions(data)
	local focus = data.focus
	local foc_buf = 0
	local files = data.files

	for _, file in ipairs(files) do
		local filepath = file.filepath
		local cursor_position = file.cursor_position
		if filepath and cursor_position and cursor_position.row and cursor_position.col then
			vim.cmd("edit " .. file.filepath)
			bfr.set_cursor_position(bufnr, cursor_position, false)

			if file.filepath == focus then
				foc_buf = bfr.get_current()
			end
		end
	end

	bfr.set_current(foc_buf)
end

-- to make sessions general use, this needs to be an option
M.root = "/home/periaate/.local/state/sessions.nvim/"

function M.save_session(path)
	local cur = M.get_cwd()
	path = path or cur
	local buffers_data = get_buffers_and_cursors()
	local j = json.encode(buffers_data)
	local p = M.root .. tpath(path) .. ".json"
	write_file(p, j)
end

function M.load_session(path)
	local cur = M.get_cwd()
	path = path or cur
	local p = M.root .. tpath(path) .. ".json"
	local res = read_file(p)
	if not res then return end
	local data = json.decode(res)
	if not data then return end
	open_files_with_positions(data)
end

function M.exists(path)
	local cur = M.get_cwd()
	path = path or cur
	local p = M.root .. tpath(path) .. ".json"
	return read_file(p) ~= nil
end

return M
