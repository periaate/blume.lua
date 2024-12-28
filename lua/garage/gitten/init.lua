local M = {
	base = function() end, -- user sets me
	hooks = {
	},
}

function M.recheck()
	if type(M.base) == "function" then M.base() end
	if not M.hooks[vim.bo.filetype] then return end

	for _, func in ipairs(M.hooks[vim.bo.filetype]) do
		if type(func) == "function" then func() end
	end
end

function M.register(pat, func)
	if not pat or type(func) ~= "function" then error("fthook function must be a function") end
	M.hooks[pat] = M.hooks[pat] or {}
	table.insert(M.hooks[pat], func)
end

function M.set_base(base)
	if not base then error("Base function not provided") end
	if type(base) ~= "function" then error("Base function must be a function") end
	M.base = base
end

function M.run()
	vim.api.nvim_create_autocmd("BufEnter", { callback = function(args) M.recheck() end })
end


return M
