-- Test that the maps in vim/init.lua pass repo text to a process as
-- separate arguments. test/argv_test.sh makes the fixtures and runs
-- this file in the fixture repo. Exit status 0 means every test passed.

local repo = vim.env.REPO
local markers = vim.env.MARKERS
local failures = 0

local function fail(msg)
	io.stderr:write("FAIL: " .. msg .. "\n")
	failures = failures + 1
end

-- These tests need no language server. gopls outlives Neovim, and it
-- writes its caches and telemetry to HOME while test/argv_test.sh
-- removes that temporary tree, so the rm fails. Turn it off before
-- the Go file opens.
vim.lsp.enable("gopls", false)

local function exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function read_args(name)
	local path = markers .. "/" .. name .. ".args"
	if not exists(path) then
		return nil
	end
	return vim.fn.readfile(path)
end

local function press(keys)
	vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

local function open(path)
	vim.cmd.edit(vim.fn.fnameescape(path))
	return vim.api.nvim_get_current_buf()
end

local function qf_texts()
	return vim.tbl_map(function(item)
		return vim.fn.bufname(item.bufnr) .. ":" .. item.text
	end, vim.fn.getqflist())
end

-- Behavior: K finds the word under the cursor as a whole word.
vim.cmd.enew()
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "needle" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
press("K")
local got = qf_texts()
if #got ~= 1 or not got[1]:match("plain%.txt:needle needles$") then
	fail("K on needle gave quickfix " .. vim.inspect(got))
end

-- Boundary: no shell and no Ex parser reads the word under the cursor.
-- Some filetypes put ", $, (, and ` in 'iskeyword'.
vim.cmd.enew()
vim.bo.iskeyword = "33-126"
local token = vim.fn.readfile(repo .. "/token.txt")[1]
vim.api.nvim_buf_set_lines(0, 0, -1, false, { token })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
pcall(press, "K")
if exists(repo .. "/kmark") then
	fail("K ran the word under the cursor in a shell")
end
got = qf_texts()
if #got ~= 1 or not got[1]:match("token%.txt:") then
	fail("K on a hostile word gave quickfix " .. vim.inspect(got))
end

-- Boundary: the SQL run map does not start psql when .db holds more
-- than a database name. A connection string sends the SQL to another
-- server, and $(...) runs in a shell.
local sql = repo .. "/q$(:>sqlmark).sql"
local notified
vim.notify = function(msg)
	notified = msg
end
for _, db in ipairs({ "x$(:>dbmark)", "host=attacker.example dbname=x" }) do
	vim.fn.writefile({ db }, repo .. "/.db")
	vim.fn.delete(markers .. "/psql.args")
	notified = nil
	open(sql)
	pcall(press, "<Space>r")
	if not notified then
		fail("the SQL run map gave no message for .db " .. vim.inspect(db))
	end
	if exists(repo .. "/dbmark") then
		fail("the SQL run map ran .db in a shell")
	end
	if read_args("psql") then
		fail("the SQL run map started psql with .db " .. vim.inspect(db))
	end
	vim.cmd("silent! only")
end

-- Behavior: with a valid .db, psql gets the database name and the
-- buffer path as separate arguments.
vim.fn.writefile({ "app_dev" }, repo .. "/.db")
vim.fn.delete(markers .. "/psql.args")
open(sql)
pcall(press, "<Space>r")
got = read_args("psql")
if not vim.deep_equal(got, { "-d", "app_dev", "-f", sql }) then
	fail("psql got " .. vim.inspect(got))
end
if exists(repo .. "/sqlmark") then
	fail("the SQL run map ran the buffer path in a shell")
end
vim.cmd("silent! only")

-- Behavior: the Go run map gives go the buffer path as one argument.
local gofile = repo .. "/m$(:>gomark).go"
open(gofile)
pcall(press, "<Space>r")
vim.wait(5000, function()
	return read_args("go") ~= nil
end, 50)
got = read_args("go")
if not vim.deep_equal(got, { "run", gofile }) then
	fail("go got " .. vim.inspect(got))
end
if exists(repo .. "/gomark") then
	fail("the Go run map ran the buffer path in a shell")
end

if failures > 0 then
	vim.cmd("cquit 1")
end
io.stdout:write("ok argv_test.lua\n")
vim.cmd("qall!")
