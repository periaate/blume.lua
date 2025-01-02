local key = {}
key.all = { 'n', 'v', 'x', 'o' }
key.modes = { 'n', 'v', 'x' }
key.opts = { noremap = true }

vim.cmd([[
function! Eatchar(pat)
let c = nr2char(getchar(0))
return (c =~ a:pat) ? '' : c
endfunction
]])

key.r = "<right>"
key.l = "<left>"
key.clean = "<BS>"
key.cmdmode = "<C-d>"
key.cmd = "<enter>"
key.eatchar = key.cmdmode .. "=Eatchar('\\s')<CR>"
key.esc = "<esc>"
key.enter = "<enter>"

key.BEG = '<esc><home>}{nn'
key.END = '<esc><end>tt'

function key.iabbrev(inp, str)
	if #inp <= 0 and #str <= 0 then return end
	vim.cmd("iabbrev " .. inp .. " " .. str)
end

function key.isnip(inp, str) key.iabbrev(inp, str .. key.eatchar) end

function key.repm(str)
	return key.esc .. "v" .. key.cmd .. [[s/\s*\zs.*\s*$/]] .. str .. "<cr>tt<end>"
end

function key.delim(str)
	return key.esc .. "v" .. key.cmd .. [[s/\v\s*(\S*)\s*(\S*)\s*(\S*)\s*(\S*)/]] .. str .. "<cr>tt<end>"
end

function key.last(cnt, str)
	return key.esc .. "v" .. key.cmd .. [[s/\v\s*\zs]] .. string.rep([[\s*(\S*)]], cnt) .. [[\s*$/]] .. str .. "<cr>tt<end>"
end

function key.sub(from, to)
	return key.esc .. "v" .. key.cmd .. [[s/\v]] .. from .. "/" .. to .. "/g" .. "<cr>tt<end>"
end

function key.set(mode, lhs, rhs, options)
	vim.keymap.set(mode, lhs, rhs, options or key.opts)
end

key.del = vim.keymap.del


return key
