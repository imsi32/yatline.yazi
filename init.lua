---@diagnostic disable: undefined-global
local section_separator_open  = ""
local section_separator_close = ""

local component_separator_open  = ""
local component_separator_close = ""

local separator_style = { bg = "#282828", fg = "#282828" }

local style_a = { bg = "#282828", fg = "#282828" }
local style_b = { bg = "#665c54", fg = "#ebdbb2" }
local style_c = { bg = "#3c3836", fg = "#a89984" }

os.setlocale("")

local function set_mode_style(mode)

	if mode.is_select then
		style_a.bg = "#d79921"
	elseif mode.is_unset then
		style_a.bg = "#d65d0e"
	else
		style_a.bg = "#a89984"
	end
end

local function set_separator_style(side, type, previous, following)

	if side == 2 then
		local temp = previous
		previous = following
		following = temp
	end

	if type == 1 then
		if previous == 1 then
			separator_style.bg = style_a.bg
		elseif previous == 2 then
			separator_style.bg = style_b.bg
		else
			separator_style.bg = style_c.bg
		end

		if following == 1 then
			separator_style.fg = style_a.bg
		elseif following == 2 then
			separator_style.fg = style_b.bg
		else
			separator_style.fg = style_c.bg
		end
	else
		if previous == 1 then
			separator_style.bg = style_a.bg
			separator_style.fg = style_a.fg
		elseif previous == 2 then
			separator_style.bg = style_b.bg
			separator_style.fg = style_b.fg
		else
			separator_style.bg = style_c.bg
			separator_style.fg = style_c.fg
		end
	end

end

local function set_component_style(component, type)

	if type == 1 then
		component:style(style_a):bold()
	elseif type == 2 then
		component:style(style_b)
	else
		component:style(style_c)
	end
end

local function connect_separator(component, side, type)
	local open = ui.Span(section_separator_open):style(separator_style)
	local close = ui.Span(section_separator_close):style(separator_style)

	if type == 2 then
		open = ui.Span(component_separator_open):style(separator_style)
		close = ui.Span(component_separator_close):style(separator_style)
	end

	if side == 1 then
		return ui.Line{open, component}
	else
		return ui.Line{component, close}
	end
end

--- Creates a component from given string.
-- Components will have style according to the given parameters.
-- @release v0.2.0
-- @param string The text which will be shown.
-- @param mode Active mode in Yazi.
-- @param side Left or right side of the either header-line or status-line.
-- @param component_type Placement of component in a section [ a | b | c ].
-- @param separator_type If component is in section where there is two or more component,
-- there is a change of two type separator.
-- @param previous_component_type Style of the component before the separator.
-- @param following_component_type Style of the component after the separator.
-- @return Line
-- @see set_mode_style
-- @see set_separator_style
-- @see set_component_style
-- @see connect_separator
-- @usage create_component_from_str("Hello World", cx.active.mode, 2, 1, 1, 2, 1)
local function create_component_from_str(string, mode, side, component_type, separator_type, previous_component_type, following_component_type)
	local span = ui.Span(" " .. string .. " ")
	set_mode_style(mode)
	set_separator_style(side, separator_type, previous_component_type, following_component_type)
	set_component_style(span, component_type)
	local line = connect_separator(span, side, separator_type)
	return line
end

function CreateDate()

	set_mode_style(cx.active.mode)
	set_separator_style(1, 1, 2, 1)

	local date = ui.Span(" " .. os.date("%A, %d %B %Y", os.time()) .. " ")
	set_component_style(date, 1)
	local date_line = connect_separator(date, 1, 1)

	set_separator_style(1, 1, 3, 2)

	local time = ui.Span(" " .. os.date("%X", os.time()) .. " ")
	set_component_style(time, 2)
	local time_line = connect_separator(time, 1, 1)

	return ui.Line( {time_line, date_line} )
end

function CreateTabs()

	local tabs = #cx.tabs
	local spans = {}

	for i = 1, tabs do

		local text = i
		if THEME.manager.tab_width > 2 then
			text = ya.truncate(text .. " " .. cx.tabs[i]:name(), { max = THEME.manager.tab_width })
		end

		if i == cx.tabs.idx then
			set_mode_style(cx.tabs[i].mode)
			set_separator_style(2, 1, 1, 3)

			local span = ui.Span(" " .. text .. " ")
			set_component_style(span, 1)
			spans[#spans + 1] = connect_separator(span, 2, 1)
		else
			local span = ui.Span(" " .. text .. " ")
			set_component_style(span, 3)

			if i == cx.tabs.idx - 1 then

				set_mode_style(cx.tabs[i + 1].mode)
				set_separator_style(2, 1, 3, 1)
				spans[#spans + 1] = connect_separator(span, 2, 1)
			else
				set_separator_style(2, 2, 3, 3)
				spans[#spans + 1] = connect_separator(span, 2, 2)
			end
		end
	end

	return ui.Line(spans)
end



function CreateName()
	local name = ui.Span(" " .. cx.active.current.hovered.name .. " ")
	set_separator_style(2, 2, 3, 3)
	set_component_style(name, 3)
	local name_line = connect_separator(name, 2, 2)
	return name_line
end

function CreateMode()
	local text = tostring(cx.active.mode):upper()
	if text == "UNSET" then
		text = "UN-SET"
	end

	local mode = ui.Span(" " .. text .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(2, 1, 1, 2)
	set_component_style(mode, 1)
	local mode_line = connect_separator(mode, 2, 1)

	return mode_line
end

function CreatePosition()
	local cursor = cx.active.current.cursor
	local length = #cx.active.current.files

	local position = ui.Span(" " .. string.format(" %2d/%-2d", cursor + 1, length) .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(1, 1, 2, 1)
	set_component_style(position, 1)
	local position_line = connect_separator(position, 1, 1)

	return position_line
end

function CreatePercentage()
	local percent = 0
	local cursor = cx.active.current.cursor
	local length = #cx.active.current.files
	if cursor ~= 0 and length ~= 0 then
		percent = math.floor((cursor + 1) * 100 / length)
	end

	local value = ""

	if percent == 0 then
		value = " Top "
	elseif percent == 100 then
		value = " Bot "
	else
		value = string.format("%3d%% ", percent)
	end

	local percent_span = ui.Span(value)
	set_separator_style(1, 1, 3, 2)
	set_component_style(percent_span, 2)
	local percent_line = connect_separator(percent_span, 1, 1)

	return percent_line
end

local function get_file_extension(filename)
	local extension = filename:match("^.+%.(.+)$")

	if extension == nil or extension == "" then
		return "null"
	else
		return extension
	end
end

function CreateFileExtension()

	local file = cx.active.current.hovered
	local icon = file:icon().text
	local cha = file.cha
	local name = "extension"

	if cha.is_dir then
		name = "dir"
	else
		name = get_file_extension(file.url:name())
	end

	local file_extension = ui.Span(" " .. icon .. " " .. name .. " ")
	set_separator_style(1, 2, 3, 3)
	set_component_style(file_extension, 3)

	local file_line = connect_separator(file_extension, 1, 2)

	return file_line
end

function CreatePermissions()
	local h = cx.active.current.hovered
	if not h then
		return ui.Line {}
	end

	local perm = h.cha:permissions()
	if not perm then
		return ui.Line {}
	end

	local spans = {}
	spans[1] = ui.Span(" ")
	set_component_style(spans[1])
	for i = 1, #perm do
		local c = perm:sub(i, i)
		local style = THEME.status.permissions_t
		if c == "-" then
			style = THEME.status.permissions_s
		elseif c == "r" then
			style = THEME.status.permissions_r
		elseif c == "w" then
			style = THEME.status.permissions_w
		elseif c == "x" or c == "s" or c == "S" or c == "t" or c == "T" then
			style = THEME.status.permissions_x
		end
		style.bg = style_c.bg
		spans[i + 1] = ui.Span(c):style(style)
	end
	spans[#perm + 2] = ui.Span(" ")
	set_component_style(spans[#perm + 2])

	set_separator_style(1, 1, 3, 3)
	local url_lin = ui.Line(spans)
	local url_line = connect_separator(url_lin, 1, 2)

	return url_line
end

function CreateSize()
	local h = cx.active.current.hovered
	if not h then
		return ui.Line {}
	end

	local size = ui.Span(" " .. ya.readable_size(h:size() or h.cha.length) .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(2, 1, 2, 3)
	set_component_style(size , 2)
	local size_line = connect_separator(size, 2, 1)

	return size_line
end

function CreateCount()
	local num_yanked = #cx.yanked
	local num_selected = #cx.active.selected

	local yanked_style, yanked_icon
	if cx.yanked.is_cut then
		yanked_style = THEME.manager.count_cut
		yanked_icon = ""
	else
		yanked_style = THEME.manager.count_copied
		yanked_icon = ""
	end

	local selected = ui.Span(string.format(" 󰻭 %d ", num_selected))
	selected:style(THEME.manager.count_selected)
	local selected_line = ui.Line{selected}

	local yanked = ui.Span(string.format(" %s %d ", yanked_icon, num_yanked))
	yanked:style(yanked_style)
	set_separator_style(2, 1, 3, 3)
	local yanked_line = connect_separator(yanked, 2, 1)

	return ui.Line{selected_line, yanked_line}
end

return {
	setup = function(st)
		Header.render = function(self, area)
			self.area = area

			return {
				ui.Paragraph(area, { CreateTabs() }):style(style_c),
				ui.Paragraph(area, { CreateDate() }):align(ui.Paragraph.RIGHT),
			}
		end

		Status.render = function(self, area)
			self.area = area

			local left = ui.Line { CreateMode(), CreateSize(), CreateName(), CreateCount()}
			local right = ui.Line { CreatePermissions(), CreateFileExtension(), CreatePercentage(), CreatePosition() }
			return {
				ui.Paragraph(area, { left }):style(style_c),
				ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
				table.unpack(Progress:render(area, right:width())),
			}
		end

	end,
}

