--- @diagnostic disable: undefined-global
--- Git Repository Status Component for Yatline
--- Shows repository state, commits ahead/behind, and file changes

local M = {}

-- Cache for git status to avoid blocking UI
local cache = {
	path = nil,
	data = nil,
	timestamp = 0,
	ttl = 5000, -- Cache TTL in milliseconds (5 seconds)
}

--- Default configuration
M.config = {
	-- Icons for different git states
	icons = {
		branch = "",      -- Branch icon
		ahead = "⇡",       -- Commits ahead
		behind = "⇣",      -- Commits behind
		clean = "✓",       -- Clean repository
		dirty = "✗",       -- Dirty repository
		added = "+",       -- Added files
		deleted = "-",     -- Deleted files
		modified = "~",    -- Modified files
		renamed = "»",     -- Renamed files
		untracked = "?",   -- Untracked files
		staged = "●",      -- Staged files
	},

	-- Colors for different states
	colors = {
		branch = "blue",
		ahead = "green",
		behind = "red",
		clean = "green",
		dirty = "yellow",
		added = "green",
		deleted = "red",
		modified = "yellow",
		renamed = "blue",
		untracked = "magenta",
		staged = "cyan",
	},

	-- Display options
	show_branch = true,
	show_ahead_behind = true,
	show_stashes = true,
	show_clean = true,  -- Show indicator when repo is clean
	compact = false,    -- Compact mode shows fewer details

	-- Performance options
	cache_ttl = 5000,   -- Cache duration in milliseconds

	-- Part separators (can be set manually or will be auto-detected)
	part_separator_open = "",
	part_separator_close = "",
}--- Get git repository information for the current directory
--- @param path string The current directory path
--- @return table|nil git_info Table containing git repository status or nil if not in a git repo
local function get_git_info(path)
	-- Use simple shell command approach
	local function run_git_cmd(args)
		local cmd = "cd " .. ya.quote(path) .. " && git " .. args .. " 2>/dev/null"
		local handle = io.popen(cmd)
		if not handle then return nil end
		local result = handle:read("*a")
		local success = handle:close()
		if not success then return nil end
		return result
	end

	-- Check if we're in a git repository
	local git_check = run_git_cmd("rev-parse --git-dir")
	if not git_check or git_check == "" then
		return nil
	end

	local info = {}

	-- Get current branch name
	local branch = run_git_cmd("symbolic-ref --short HEAD")
	if branch and branch ~= "" then
		info.branch = branch:gsub("%s+", "")
	else
		-- Detached HEAD - get short commit hash
		local hash = run_git_cmd("rev-parse --short HEAD")
		if hash and hash ~= "" then
			info.branch = hash:gsub("%s+", "")
			info.detached = true
		end
	end

	-- Get ahead/behind counts
	local ahead_behind = run_git_cmd("rev-list --left-right --count HEAD...@{upstream}")
	if ahead_behind and ahead_behind ~= "" then
		local ahead, behind = ahead_behind:match("(%d+)%s+(%d+)")
		info.ahead = tonumber(ahead) or 0
		info.behind = tonumber(behind) or 0
	else
		info.ahead = 0
		info.behind = 0
	end

	-- Get file status counts
	local status = run_git_cmd("status --porcelain --untracked-files=all")

	info.staged = 0
	info.modified = 0
	info.deleted = 0
	info.renamed = 0
	info.untracked = 0
	info.added = 0

	if status and status ~= "" then
		for line in status:gmatch("[^\r\n]+") do
			local index_status = line:sub(1, 1)
			local work_status = line:sub(2, 2)

			-- Staged changes
			if index_status == "A" then
				info.staged = info.staged + 1
				info.added = info.added + 1
			elseif index_status == "M" then
				info.staged = info.staged + 1
				info.modified = info.modified + 1
			elseif index_status == "D" then
				info.staged = info.staged + 1
				info.deleted = info.deleted + 1
			elseif index_status == "R" then
				info.staged = info.staged + 1
				info.renamed = info.renamed + 1
			end

			-- Working tree changes
			if work_status == "M" then
				info.modified = info.modified + 1
			elseif work_status == "D" then
				info.deleted = info.deleted + 1
			end

			-- Untracked files
			if index_status == "?" and work_status == "?" then
				info.untracked = info.untracked + 1
			end
		end
	end

	-- Check if repository is clean
	info.clean = (info.staged + info.modified + info.deleted + info.untracked + info.added + info.renamed) == 0

	-- Get stash count (optional)
	if M.config.show_stashes then
		local stash_list = run_git_cmd("stash list")
		if stash_list and stash_list ~= "" then
			local count = 0
			for _ in stash_list:gmatch("[^\r\n]+") do
				count = count + 1
			end
			info.stashes = count
		else
			info.stashes = 0
		end
	else
		info.stashes = 0
	end

	return info
end

--- Format git information as a coloreds array
--- @param info table Git repository information
--- @param config table Configuration options
--- @return table coloreds Array of {text, color} pairs
local function format_git_info(info, config)
	local coloreds = {}
	local icons = config.icons
	local colors = config.colors

	-- Get part separators from Yatline config
	local part_sep_open = ""
	local part_sep_close = ""
	if Yatline and Yatline.config and Yatline.config.part_separator then
		part_sep_open = Yatline.config.part_separator.open or ""
		part_sep_close = Yatline.config.part_separator.close or ""
	end

	-- Add opening separator if we have content
	if part_sep_open ~= "" then
		table.insert(coloreds, { part_sep_open .. " ", "reset" })
	end

	-- Branch name
	if config.show_branch and info.branch then
		local branch_text = icons.branch .. "" .. info.branch
		if info.detached then
			branch_text = branch_text .. " (detached)"
		end
		table.insert(coloreds, { branch_text .. " ", colors.branch })
	end

	-- Ahead/Behind
	if config.show_ahead_behind then
		if info.ahead > 0 then
			table.insert(coloreds, { icons.ahead .. info.ahead .. " ", colors.ahead })
		end
		if info.behind > 0 then
			table.insert(coloreds, { icons.behind .. info.behind .. " ", colors.behind })
		end
	end

	-- Repository state
	if info.clean then
		if config.show_clean then
			table.insert(coloreds, { icons.clean .. " ", colors.clean })
		end
	else
		table.insert(coloreds, { icons.dirty .. " ", colors.dirty })
	end

	-- File changes (detailed or compact)
	if not info.clean then
		if config.compact then
			-- Compact mode: just show if there are changes
			local total = info.staged + info.modified + info.deleted + info.untracked
			if total > 0 then
				table.insert(coloreds, { "(" .. total .. ") ", colors.dirty })
			end
		else
			-- Detailed mode: show each type of change
			if info.staged > 0 then
				table.insert(coloreds, { icons.staged .. info.staged .. " ", colors.staged })
			end
			if info.added > 0 then
				table.insert(coloreds, { icons.added .. info.added .. " ", colors.added })
			end
			if info.modified > 0 then
				table.insert(coloreds, { icons.modified .. info.modified .. " ", colors.modified })
			end
			if info.deleted > 0 then
				table.insert(coloreds, { icons.deleted .. info.deleted .. " ", colors.deleted })
			end
			if info.renamed > 0 then
				table.insert(coloreds, { icons.renamed .. info.renamed .. " ", colors.renamed })
			end
			if info.untracked > 0 then
				table.insert(coloreds, { icons.untracked .. info.untracked .. " ", colors.untracked })
			end
		end
	end

	-- Stashes (optional)
	if config.show_stashes and info.stashes > 0 then
		table.insert(coloreds, { "📦" .. info.stashes .. " ", colors.branch })
	end

	-- Add closing separator
	if part_sep_close ~= "" and #coloreds > 0 then
		table.insert(coloreds, { part_sep_close, "reset" })
	end

	return coloreds
end

--- Setup function to configure the git status component
--- @param user_config? table User configuration to override defaults
function M.setup(user_config)
	if user_config then
		-- Merge user config with defaults
		for key, value in pairs(user_config) do
			if type(value) == "table" and M.config[key] then
				for k, v in pairs(value) do
					M.config[key][k] = v
				end
			else
				M.config[key] = value
			end
		end
	end
end

--- Get git repository status as a coloreds array
--- @param custom_config? table Optional configuration override for this call
--- @return table coloreds Array of {text, color} pairs, empty if not in a git repo
function M.get_status(custom_config)
	local config = custom_config or M.config

	-- Get current directory from Yazi
	local cwd = cx.active.current.cwd
	if not cwd then
		return {}
	end

	local path = tostring(cwd)

	-- Check cache
	local now = os.time() * 1000 -- Convert to milliseconds
	if cache.path == path and cache.data and (now - cache.timestamp) < config.cache_ttl then
		return cache.data
	end

	local info = get_git_info(path)

	if not info then
		-- Clear cache if not in git repo
		cache.path = nil
		cache.data = nil
		return {}
	end

	local result = format_git_info(info, config)

	-- Update cache
	cache.path = path
	cache.data = result
	cache.timestamp = now

	return result
end

--- Create a git status component for use in yatline configuration
--- This is the entry point for using this component in yatline
--- @param custom_config? table Optional configuration override
--- @return table component_config Configuration table for yatline
function M.component(custom_config)
	return {
		type = "coloreds",
		custom = true,
		name = function()
			return M.get_status(custom_config)
		end
	}
end

-- Auto-register with Yatline if available
if Yatline and Yatline.coloreds and Yatline.coloreds.get then
	Yatline.coloreds.get.git_repo_status = function()
		return M.get_status()
	end
end

return M
