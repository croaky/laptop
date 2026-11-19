-- Test the trust rules in vim/init.lua. test/nvim_test.sh makes the
-- fixtures and runs this file. Exit status 0 means every test passed.

local markers = vim.env.MARKERS
local failures = 0

local function fail(msg)
	io.stderr:write("FAIL: " .. msg .. "\n")
	failures = failures + 1
end

local function marker(name)
	return vim.uv.fs_stat(markers .. "/" .. name) ~= nil
end

local function open(path)
	vim.cmd.edit(vim.fn.fnameescape(path))
	return vim.api.nvim_get_current_buf()
end

-- Behavior: Neovim, and each program it starts, gets a PATH with only
-- absolute directories.
for _, dir in ipairs(vim.split(vim.env.PATH, ":", { plain = true })) do
	if dir:sub(1, 1) ~= "/" then
		fail("PATH has a relative entry: " .. vim.inspect(dir))
	end
end

-- Behavior: drawing the status line runs no project git.
_G.get_user()
if marker("git") then
	fail("the status line ran ./bin/git")
end

local conform = require("conform")

-- Behavior: the dprint formatter runs ~/.local/bin/dprint by path,
-- never node_modules/.bin/dprint from the project.
local buf = open(vim.env.UNTRUSTED .. "/x.json")
local info = conform.get_formatter_info("dprint", buf)
local want = vim.fn.expand("~/.local/bin/dprint")
if info.command ~= want then
	fail("dprint command is " .. tostring(info.command) .. ", want " .. want)
end

-- Boundary: in an untrusted repo, dprint reads the user's config, not
-- the project dprint.json. The project config sets indentWidth 8.
conform.format({ bufnr = buf, async = false, timeout_ms = 10000, formatters = { "dprint" } })
if marker("dprint") then
	fail("format ran node_modules/.bin/dprint")
end
local line = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] or ""
if line ~= '  "a": {' then
	fail("dprint did not format with the user config in an untrusted repo: " .. vim.inspect(line))
end

-- Behavior: in a trusted repo, dprint keeps the project config.
buf = open(vim.env.TRUSTED .. "/x.json")
conform.format({ bufnr = buf, async = false, timeout_ms = 10000, formatters = { "dprint" } })
line = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] or ""
if not line:match("^        ") then
	fail("dprint did not read the project config in a trusted repo")
end

-- Boundary: in an untrusted repo, a go.mod that pins pgfmt selects no
-- SQL formatter, so go tool builds no repo code.
local function sql_formatters(dir)
	local b = open(dir .. "/q.sql")
	return vim.tbl_map(function(f)
		return f.name
	end, conform.list_formatters(b))
end
local got = sql_formatters(vim.env.UNTRUSTED)
if #got ~= 0 then
	fail("untrusted SQL formatters are " .. vim.inspect(got) .. ", want {}")
end

-- Behavior: in a trusted repo, the pgfmt pin still selects pgfmt.
got = sql_formatters(vim.env.TRUSTED)
if not vim.deep_equal(got, { "pgfmt" }) then
	fail("trusted SQL formatters are " .. vim.inspect(got) .. ', want { "pgfmt" }')
end

if failures > 0 then
	vim.cmd("cquit 1")
end
io.stdout:write("ok nvim_test\n")
vim.cmd("qall!")
