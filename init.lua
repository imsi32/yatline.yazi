--- @diagnostic disable: undefined-global
--- @alias Mode Mode Comes from Yazi.
--- @alias Line Line Comes from Yazi.
--- @alias Span Span Comes from Yazi.
--- @alias Side # [ LEFT ... RIGHT ]
--- | `enums.LEFT` # The left side of either the header-line or status-line. [ LEFT ... ]
--- | `enums.RIGHT` # The right side of either the header-line or status-line. [ ... RIGHT]
--- @alias SeparatorType
--- | `enums.OUTER` # Separators on the outer side of sections. [ c o | c o | c o ... ] or [ ... o c | o c | o c ]
--- | `enums.INNER` # Separators on the inner side of sections. [ c i c | c i c | c i c ... ] or [ ... c i c | c i c | c i c ]
--- @alias ComponentType
--- | `enums.A` # Components on the first section. [ A | | ... ] or [ ... | | A ]
--- | `enums.B` # Components on the second section. [ | B | ... ] or [ ... | B | ]
--- | `enums.C` # Components on the third section. [ | | C ... ] or [ ... C | | ]

local section_separator_open  = ""
local section_separator_close = ""

local part_separator_open  = ""
local part_separator_close = ""

local separator_style = { bg = "black", fg = "black" }

local style_a = { bg = "black", fg = "black" }
local style_b = { bg = "#665c54", fg = "#ebdbb2" }
local style_c = { bg = "#3c3836", fg = "#a89984" }

local Side = { LEFT = 0, RIGHT = 1 }
local SeparatorType = { OUTER = 0, INNER = 1 }
local ComponentType = { A = 0, B = 1, C = 2 }

os.setlocale("")

--- Sets the background of style_a according to the tab's mode.
--- @param mode Mode The mode of the active tab.
--- @see cx.active.mode To get the active tab's mode.
local function set_mode_style(mode)
	if mode.is_select then
		style_a.bg = "#d79921"
	elseif mode.is_unset then
		style_a.bg = "#d65d0e"
	else
		style_a.bg = "#a89984"
	end
end

--- Sets the style of the separator according to the parameters.
--- While selecting component type of both previous and following components,
--- always think separator is in middle of two components
--- and previous component is in left side and following component is in right side.
--- Thus, side of component does not important when choosing these two components.
--- @param side Side Left or right side of the either header-line or status-line.
--- @param separator_type SeparatorType Where will there be a separator in the section.
--- @param previous_component_type ComponentType The type of the component before the separator.
--- @param following_component_type ComponentType The type of the component after the separator.
local function set_separator_style(side, separator_type, previous_component_type, following_component_type)
	if side == Side.LEFT then
		local temp = previous_component_type
		previous_component_type = following_component_type
		following_component_type = temp
	end

	if separator_type == SeparatorType.OUTER then
		if previous_component_type == ComponentType.A then
			separator_style.bg = style_a.bg
		elseif previous_component_type == ComponentType.B then
			separator_style.bg = style_b.bg
		else
			separator_style.bg = style_c.bg
		end

		if following_component_type == ComponentType.A then
			separator_style.fg = style_a.bg
		elseif following_component_type == ComponentType.B then
			separator_style.fg = style_b.bg
		else
			separator_style.fg = style_c.bg
		end
	else
		if previous_component_type == ComponentType.A then
			separator_style.bg = style_a.bg
			separator_style.fg = style_a.fg
		elseif previous_component_type == ComponentType.B then
			separator_style.bg = style_b.bg
			separator_style.fg = style_b.fg
		else
			separator_style.bg = style_c.bg
			separator_style.fg = style_c.fg
		end
	end
end

---Sets the style of the component according to the its type.
--- @param component Span Component that will be styled.
--- @param component_type ComponentType Which section component will be in [ a | b | c ].
--- @see Style To see how to style, in Yazi's documentation.
local function set_component_style(component, component_type)
	if component_type == ComponentType.A then
		component:style(style_a):bold()
	elseif component_type == ComponentType.B then
		component:style(style_b)
	else
		component:style(style_c)
	end
end

--- Connects component to a separator.
--- @param component Span Component that will be connected to separator.
--- @param side Side Left or right side of the either header-line or status-line.
--- @param separator_type SeparatorType Where will there be a separator in the section.
--- @return Line line A Line which has component and separator.
local function connect_separator(component, side, separator_type)
	local open, close
	if separator_type == SeparatorType.OUTER then
		open = ui.Span(section_separator_open)
		close = ui.Span(section_separator_close)
	else
		open = ui.Span(part_separator_open)
		close = ui.Span(part_separator_close)
	end

	open:style(separator_style)
	close:style(separator_style)

	if side == Side.LEFT then
		return ui.Line{component, close}
	else
		return ui.Line{open, component}
	end
end

--- Creates a component from given string according to other parameters.
--- @param string string The text which will be shown inside of the component.
--- @param mode Mode The mode of the active tab.
--- @param side Side Left or right side of the either header-line or status-line.
--- @param component_type ComponentType Which section component will be in [ a | b | c ].
--- @param separator_type SeparatorType Where will there be a separator in the section.
--- @param previous_component_type ComponentType The type of the component before the separator.
--- @param following_component_type ComponentType The type of the component after the separator.
--- @return Line line Customized Line which follows desired style of the parameters.
--- @see set_mode_style To know how mode style selected.
--- @see set_separator_style To know how separator style applied.
--- @see set_component_style To know how component style applied.
--- @see connect_separator To know how component and separator connected.
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
	set_separator_style(Side.RIGHT, SeparatorType.OUTER, ComponentType.B, ComponentType.A)

	local date = ui.Span(" " .. os.date("%A, %d %B %Y", os.time()) .. " ")
	set_component_style(date, ComponentType.A)
	local date_line = connect_separator(date, Side.RIGHT, SeparatorType.OUTER)

	set_separator_style(Side.RIGHT, SeparatorType.OUTER, ComponentType.C, ComponentType.B)

	local time = ui.Span(" " .. os.date("%X", os.time()) .. " ")
	set_component_style(time, ComponentType.B)
	local time_line = connect_separator(time, Side.RIGHT, SeparatorType.OUTER)

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
			set_separator_style(Side.LEFT, SeparatorType.OUTER, ComponentType.A, ComponentType.C)

			local span = ui.Span(" " .. text .. " ")
			set_component_style(span, ComponentType.A)
			spans[#spans + 1] = connect_separator(span, Side.LEFT, SeparatorType.OUTER)
		else
			local span = ui.Span(" " .. text .. " ")
			set_component_style(span, ComponentType.C)

			if i == cx.tabs.idx - 1 then

				set_mode_style(cx.tabs[i + 1].mode)
				set_separator_style(Side.LEFT, SeparatorType.OUTER, ComponentType.C, ComponentType.A)
				spans[#spans + 1] = connect_separator(span, Side.LEFT, SeparatorType.OUTER)
			else
				set_separator_style(Side.LEFT, SeparatorType.INNER, ComponentType.C, ComponentType.C)
				spans[#spans + 1] = connect_separator(span, Side.LEFT, SeparatorType.INNER)
			end
		end
	end

	return ui.Line(spans)
end



function CreateName()
	local name = ui.Span(" " .. cx.active.current.hovered.name .. " ")
	set_separator_style(Side.LEFT, SeparatorType.INNER, ComponentType.C, ComponentType.C)
	set_component_style(name, ComponentType.C)
	local name_line = connect_separator(name, Side.LEFT, SeparatorType.INNER)
	return name_line
end

function CreateMode()
	local text = tostring(cx.active.mode):upper()
	if text == "UNSET" then
		text = "UN-SET"
	end

	local mode = ui.Span(" " .. text .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(Side.LEFT, SeparatorType.OUTER, ComponentType.A, ComponentType.B)
	set_component_style(mode, ComponentType.A)
	local mode_line = connect_separator(mode, Side.LEFT, SeparatorType.OUTER)

	return mode_line
end

function CreatePosition()
	local cursor = cx.active.current.cursor
	local length = #cx.active.current.files

	local position = ui.Span(" " .. string.format(" %2d/%-2d", cursor + 1, length) .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(Side.RIGHT, SeparatorType.OUTER, ComponentType.B, ComponentType.A)
	set_component_style(position, ComponentType.A)
	local position_line = connect_separator(position, Side.RIGHT, SeparatorType.OUTER)

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
	set_separator_style(Side.RIGHT, SeparatorType.OUTER, ComponentType.C, ComponentType.B)
	set_component_style(percent_span, ComponentType.B)
	local percent_line = connect_separator(percent_span, Side.RIGHT, SeparatorType.OUTER)

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
	set_separator_style(Side.RIGHT, SeparatorType.INNER, ComponentType.C, ComponentType.C)
	set_component_style(file_extension, ComponentType.C)

	local file_line = connect_separator(file_extension, Side.RIGHT, SeparatorType.INNER)

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

	set_separator_style(Side.RIGHT, SeparatorType.OUTER, ComponentType.C, ComponentType.C)
	local url_lin = ui.Line(spans)
	local url_line = connect_separator(url_lin, Side.RIGHT, SeparatorType.INNER)

	return url_line
end

function CreateSize()
	local h = cx.active.current.hovered
	if not h then
		return ui.Line {}
	end

	local size = ui.Span(" " .. ya.readable_size(h:size() or h.cha.length) .. " ")
	set_mode_style(cx.active.mode)
	set_separator_style(Side.LEFT, SeparatorType.OUTER, ComponentType.B, ComponentType.C)
	set_component_style(size , ComponentType.B)
	local size_line = connect_separator(size, Side.LEFT, SeparatorType.OUTER)

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
	set_separator_style(Side.LEFT, SeparatorType.OUTER, ComponentType.C, ComponentType.C)
	local yanked_line = connect_separator(yanked, Side.LEFT, SeparatorType.OUTER)

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

