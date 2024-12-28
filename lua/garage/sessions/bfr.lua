local bfr = {}

local blume = require("blume")

function bfr.is_valid(bufnr)
	bufnr = bufnr or 0
	return vim.api.nvim_buf_is_valid(bufnr)
end

function bfr.is_loaded(bufnr)
	bufnr = bufnr or 0
	if bfr.is_valid(bufnr) then
		return vim.api.nvim_buf_is_loaded(bufnr)
	end
	return false
end

function bfr.get_name(bufnr)
	bufnr = bufnr or 0
	if bfr.is_loaded(bufnr) then
		return vim.api.nvim_buf_get_name(bufnr)
	end
	return ""
end

function bfr.set_current(bufnr)
	bufnr = bufnr or 0
	if bfr.is_loaded(bufnr) then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

function bfr.get_current() return vim.api.nvim_get_current_buf() end

function bfr.get_cursor_position(bufnr)
	bufnr = bufnr or 0
	if bfr.is_loaded(bufnr) then
		local win_id = vim.fn.bufwinid(bufnr)
		if win_id ~= -1 and win_id then
			local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
			return { row = cursor_pos[1], col = cursor_pos[2] }
		end
	end
	return { row = 1, col = 0 }
end

function bfr.list_all()
	return vim.api.nvim_list_bufs()
end

function bfr.list_loaded()
	local all = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(all) do
		all = blume.filter(bfr.is_loaded)(all)
	end
	return all
end

function bfr.set_cursor_position(bufnr, cursor_position, restore)
	local rest_buf = -1
	if restore then rest_buf = bfr.get_current() end
	bufnr = bufnr or 0
	if bfr.is_loaded(bufnr) then
		vim.api.nvim_set_current_buf(bufnr)
		if cursor_position.row > 1 then
			vim.cmd('normal! ' .. cursor_position.row-1 .. 'j')
		end
		vim.cmd('normal! ' .. cursor_position.col .. 'l')
	end
	if rest_buf ~= -1 then bfr.set_current(rest_buf) end
end

return bfr
