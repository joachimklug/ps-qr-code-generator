-- PrusaSlicer provides require at execution time and resolves paths from the command file.
-- lib/qrencode.lua is vendored from speedata/luaqrcode. See lib/VENDORED.md.

-- Returns the smallest nozzle diameter of the selected printer, or nil if it is unknown.
-- This is a best-effort check, so API errors never block generating the plate.
local function find_smallest_nozzle_diameter()
    local ok, smallest = pcall(function()
        local result
        for _, tool in ipairs(api.project:current_bed():printer_config().tools) do
            local diameter = tool:nozzle_diameter()
            -- Ignore values that do not look like millimeters.
            if type(diameter) == "number" and diameter >= 0.05 and diameter <= 2
                and (result == nil or diameter < result) then
                result = diameter
            end
        end
        return result
    end)
    if ok then
        return smallest
    end
    return nil
end

local function encode(payload, encoding_error)
    local encoder = require("lib/qrencode")
    local ran, encoded, matrix = pcall(encoder.qrcode, payload)
    if ran and encoded then
        return matrix
    end

    -- pcall returns the error as its second value. qrcode returns false and a message.
    local reason = ran and matrix or encoded
    if type(reason) ~= "string" then
        error(encoding_error, 0)
    end
    if reason:find("Data too long", 1, true) then
        error("The content is too long for a QR code. Shorten it.", 0)
    end
    error(encoding_error .. " Details: " .. reason, 0)
end

local TWO_COLOR_CHANGE = "Two colors: color change (one nozzle)"
local TWO_COLOR_TOOL = "Two colors: second tool (multi-tool)"
local PATTERN_TOOL = 2

-- Reads the layer heights of the current bed's print preset in mm.
local function read_layer_heights(bed)
    local ok, layer, first = pcall(function()
        local presets = bed:print_presets()
        local layer_height = presets:value("layer_height")
        local first_layer_height = presets:value("first_layer_height")
        -- first_layer_height can be a percentage of the layer height.
        if type(first_layer_height) ~= "number" and first_layer_height ~= nil then
            first_layer_height = first_layer_height:get_abs_value(layer_height)
        end
        return layer_height, first_layer_height
    end)
    if not ok or type(layer) ~= "number" or layer <= 0 or type(first) ~= "number" or first <= 0 then
        error("Could not read the layer heights from the print preset, so the color change can't be placed. Choose Two colors: off, or check the print preset.", 0)
    end
    return layer, first
end

local function read_tool_count(bed)
    local ok, count = pcall(function()
        return bed:printer_config().tool_count
    end)
    if ok and type(count) == "number" then
        return count
    end
    return nil
end

local function add_qr_plate(payload, dimensions, encoding_error)
    local qr_geometry = require("lib/qr_geometry")
    local utils = require("lib/utils")

    local spec = utils.validate_dimensions(dimensions)
    local matrix = encode(payload, encoding_error)
    local layout = utils.resolve_layout(spec, #matrix, find_smallest_nozzle_diameter())

    local pattern_volumes = qr_geometry.make_pattern_volumes(matrix, {
        module_size = layout.module_size,
        border_left = layout.border_left,
        border_bottom = layout.border_bottom,
        base_height = spec.base_height,
        pattern_height = spec.pattern_height
    })
    -- Build the keychain tab before changing the bed, so a problem leaves the bed unchanged.
    local tab_volumes = {}
    local tab = utils.resolve_keychain_tab(spec, layout)
    if tab then
        tab_volumes = require("lib/keychain").make_tab_volumes(tab, spec.base_height, spec.pattern_height)
    end

    -- Check the two-color mode before adding anything, so a problem leaves the bed unchanged.
    local bed = api.project:current_bed()
    local color_change_z
    if dimensions.two_color == TWO_COLOR_CHANGE then
        local layer_height, first_layer_height = read_layer_heights(bed)
        color_change_z = utils.first_pattern_layer_z(spec.base_height, spec.pattern_height, layer_height, first_layer_height)
    elseif dimensions.two_color == TWO_COLOR_TOOL then
        local tool_count = read_tool_count(bed)
        if tool_count == nil or tool_count < PATTERN_TOOL then
            error("The selected printer has only one tool. Choose the color change (one nozzle) instead.", 0)
        end
        for _, volume in ipairs(pattern_volumes) do
            -- A volume with params defaults to a modifier, so mark it as a solid part explicitly.
            volume.type = VolumeType.Solid
            volume.params = { extruder = PATTERN_TOOL }
        end
    end

    if color_change_z then
        -- Inserted as custom G-code: the printer pauses for the filament change, but PrusaSlicer's
        -- preview stays one color and the print time estimate doesn't include the change.
        -- Insert it before add_object: PrusaSlicer 3.0.0-alpha14 only picks up the G-code at the
        -- next scene change, and adding the plate is that change.
        api.project:insert_layer_custom_gcode(bed, color_change_z, "M600")
    end
    -- The tab prints with the plate, so it joins the pattern only after the pattern got its tool.
    local other_volumes = {}
    for _, volumes in ipairs({ pattern_volumes, tab_volumes }) do
        for _, volume in ipairs(volumes) do
            other_volumes[#other_volumes + 1] = volume
        end
    end
    api.project:add_object {
        mesh = api.make_cube(layout.plate_width, layout.plate_height, spec.base_height),
        other_volumes = other_volumes
    }
end

return { add_qr_plate = add_qr_plate }
