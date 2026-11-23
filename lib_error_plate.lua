-- PrusaSlicer 3.0.0-alpha14 does not show errors raised by a plugin command, so a failed
-- check looks as if nothing happened. run() catches the error and adds a plate with the
-- message embossed on it to the bed instead.

local LINE_HEIGHT = 6
local LINE_SPACING = 9
local MAX_LINE_CHARS = 34
local MAX_LINES = 8
local MARGIN = 5
local PLATE_HEIGHT = 1
local TEXT_DEPTH = 0.6
local TITLE = "QR code not created:"

-- PrusaSlicer may run plugins without the utf8 library; fall back to bytes then.
local function char_count(text)
    return (utf8 and utf8.len(text)) or #text
end

local function split_at(text, count)
    local index = count + 1
    if utf8 and utf8.len(text) then
        index = utf8.offset(text, count + 1)
    end
    return text:sub(1, index - 1), text:sub(index)
end

local function wrap(text)
    local lines = {}
    local line = ""
    for word in text:gmatch("%S+") do
        while char_count(word) > MAX_LINE_CHARS do
            local head, tail = split_at(word, MAX_LINE_CHARS)
            if line ~= "" then
                lines[#lines + 1] = line
                line = ""
            end
            lines[#lines + 1] = head
            word = tail
        end
        if line == "" then
            line = word
        elseif char_count(line) + 1 + char_count(word) <= MAX_LINE_CHARS then
            line = line .. " " .. word
        else
            lines[#lines + 1] = line
            line = word
        end
    end
    if line ~= "" then
        lines[#lines + 1] = line
    end
    if #lines > MAX_LINES then
        for index = #lines, MAX_LINES + 1, -1 do
            lines[index] = nil
        end
        lines[MAX_LINES] = lines[MAX_LINES] .. " ..."
    end
    return lines
end

-- Errors raised with error(message, 0) are messages for the user. Anything else, such as
-- "lib_utils.lua:12: attempt to index a nil value", is a bug in the plugin.
local function describe(err)
    local message = tostring(err)
    if type(err) ~= "string" or message:match("^[^\n]-%.lua:%d+: ") then
        return "Unexpected plugin error. Please report it: " .. message
    end
    return message
end

local function add_error_plate(message)
    local lines = { TITLE }
    for _, line in ipairs(wrap(message)) do
        lines[#lines + 1] = line
    end

    -- Always pass a font. In PrusaSlicer 3.0.0-alpha14, emboss_text without one crashes the
    -- whole app (confirmed 2026-11-22), even though the API marks the font as optional.
    local font = api.get_default_font()
    if font == nil then
        error("No default font available", 0)
    end

    local text_volumes = {}
    local text_width = 0
    for index, line in ipairs(lines) do
        local mesh = api.emboss_text { font = font, text = line, depth = TEXT_DEPTH, line_height = LINE_HEIGHT }
        local bounds = mesh:bounds()
        text_width = math.max(text_width, bounds.max_x - bounds.min_x)
        -- Place each line by its bounding box, so the mesh origin does not matter.
        text_volumes[#text_volumes + 1] = {
            mesh = mesh,
            translate = {
                x = MARGIN - bounds.min_x,
                y = MARGIN + (#lines - index) * LINE_SPACING - bounds.min_y,
                z = PLATE_HEIGHT - bounds.min_z
            }
        }
    end

    local plate_width = text_width + 2 * MARGIN
    local plate_depth = (#lines - 1) * LINE_SPACING + LINE_HEIGHT + 2 * MARGIN
    api.project:add_object {
        mesh = api.make_cube(plate_width, plate_depth, PLATE_HEIGHT),
        other_volumes = text_volumes
    }
end

-- Runs generate(opts). If it fails, shows the error on the bed. If even that fails,
-- raises the original message so it still reaches PrusaSlicer's log.
local function run(generate, opts)
    local ok, err = pcall(generate, opts)
    if ok then
        return
    end
    local message = describe(err)
    print("QR Code Generator: " .. message)
    if not pcall(add_error_plate, message) then
        error(message, 0)
    end
end

return { run = run }
