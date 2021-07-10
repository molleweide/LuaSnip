local FunctionNode = require("luasnip.nodes.node").Node:new()
local util = require("luasnip.util.util")
local lambda = require("luasnip.util.lambda")

local function F(fn, args, ...)
	if lambda.isPE(fn) then
		local function _concat(tbl)
			return table.concat(tbl, "\n")
		end
		local expr = lambda.instantiate(fn)
		fn = function(args)
			local inputs = vim.tbl_map(_concat, args)
			local out = expr(unpack(inputs))
			return vim.split(out, "\n")
		end
	end
	return FunctionNode:new({
		fn = fn,
		args = util.wrap_value(args),
		type = 2,
		markers = {},
		user_args = { ... },
	})
end

function FunctionNode:get_args()
	local args = {}
	for i, node in ipairs(self.args) do
		args[i] = node:get_text()
	end
	args[#args + 1] = self.parent
	return args
end

function FunctionNode:input_enter()
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
		"n",
		true
	)
	util.normal_move_on_mark_insert(self.markers[1])
end

function FunctionNode:update()
	local text = util.wrap_value(
		self.fn(self:get_args(), unpack(self.user_args))
	)
	self.parent:set_text(self, text)
end

return {
	F = F,
}
