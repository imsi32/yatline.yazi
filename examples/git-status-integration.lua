-- Example integration of git-repo-status component with yatline
-- Save this in your ~/.config/yazi/init.lua

-- Initialize yatline with your configuration
require("yatline"):setup({
	-- Configure separators
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	-- Configure style
	style_a = {
		fg = "black",
		bg_mode = {
			normal = "#a89984",
			select = "#d79921",
			un_set = "#d65d0e"
		}
	},
	style_b = { bg = "#665c54", fg = "#ebdbb2" },
	style_c = { bg = "#3c3836", fg = "#a89984" },

	-- Configure header line
	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {},
			section_c = {},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "date", params = { "%A, %d %B %Y" } },
			},
			section_b = {
				{ type = "string", custom = false, name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	-- Configure status line with git status component
	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_name" },
				-- Add git status component here
				{ type = "coloreds", custom = false, name = "git_repo_status" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
			},
		},
	},
})

-- Initialize git status component (auto-registers with Yatline)
require("yatline.git-repo-status"):setup()

-- OR: Custom setup with your preferences
--[[
require("yatline.git-repo-status"):setup({
	-- Customize icons (using Nerd Font icons)
	icons = {
		branch = "󰘬",      -- Nerd Font git branch icon
		ahead = "⇡",
		behind = "⇣",
		clean = "",
		dirty = "",
		added = "",
		deleted = "",
		modified = "",
		renamed = "󰁕",
		untracked = "",
		staged = "",
	},

	-- Customize colors (match your theme)
	colors = {
		branch = "#89b4fa",      -- Catppuccin blue
		ahead = "#a6e3a1",       -- Catppuccin green
		behind = "#f38ba8",      -- Catppuccin red
		clean = "#a6e3a1",       -- Catppuccin green
		dirty = "#f9e2af",       -- Catppuccin yellow
		added = "#a6e3a1",
		deleted = "#f38ba8",
		modified = "#f9e2af",
		renamed = "#89b4fa",
		untracked = "#cba6f7",   -- Catppuccin mauve
		staged = "#94e2d5",      -- Catppuccin teal
	},

	-- Display options
	show_branch = true,
	show_ahead_behind = true,
	show_stashes = false,
	show_clean = true,
	compact = false,  -- Set to true for minimal display
})
--]]
