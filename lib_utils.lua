local MIN_FEATURE_SIZE = 0.01
local MAX_MODEL_SIZE = 1000
local MAX_BORDER_BYTES = 256
-- The QR standard asks for a quiet zone of four modules on each side of the pattern.
local QUIET_ZONE_MODULES = 4
local AUTO_BORDER = "auto"

-- Keychain tab. The tab sticks out above the plate, so the hole never cuts into the quiet zone.
local MIN_HOLE_DIAMETER = 1
local MAX_HOLE_DIAMETER = 30
-- The ring around the hole is at least this wide, or half the hole diameter for larger holes.
local MIN_TAB_WALL = 2.5
-- How far the tab reaches into the plate, so the two fuse into one part.
local TAB_OVERLAP = 0.5

local BORDER_INPUT_ERROR = "Enter auto, one nonnegative border value in mm, or four comma-separated values in top, right, bottom, left order. Each value can be auto or mm. Use a decimal point for fractions, such as 2.5."

local function is_finite_positive_number(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

local function parse_border_field(field)
    if field:match("^%s*(.-)%s*$"):lower() == AUTO_BORDER then
        return AUTO_BORDER
    end
    local decimal = field:match("^%s*(%d*%.?%d*)%s*$")
    local width = decimal and tonumber(decimal)
    if width ~= 0 and not is_finite_positive_number(width) then
        error(BORDER_INPUT_ERROR, 0)
    end
    -- Keep plate dimension sums in floating point even for whole millimeters.
    return width + 0.0
end

-- Returns each side as a width in mm or as AUTO_BORDER, which resolve_layout replaces
-- with the quiet zone once the QR grid size is known.
local function parse_borders(border)
    if type(border) ~= "string" then
        error(BORDER_INPUT_ERROR, 0)
    end
    -- The decimal pattern can backtrack on malformed input.
    if #border > MAX_BORDER_BYTES then
        error("The border field must be at most " .. MAX_BORDER_BYTES .. " bytes.", 0)
    end

    local borders = {}
    for field in (border .. ","):gmatch("([^,]*),") do
        if #borders == 4 then
            error(BORDER_INPUT_ERROR, 0)
        end
        borders[#borders + 1] = parse_border_field(field)
    end

    if #borders == 1 then
        local width = borders[1]
        return { top = width, right = width, bottom = width, left = width }
    end
    if #borders ~= 4 then
        error(BORDER_INPUT_ERROR, 0)
    end
    return { top = borders[1], right = borders[2], bottom = borders[3], left = borders[4] }
end

local function validate_height(value, label)
    if type(value) ~= "number" or not (value >= MIN_FEATURE_SIZE and value <= MAX_MODEL_SIZE) then
        error(("%s must be between %g and %g mm."):format(label, MIN_FEATURE_SIZE, MAX_MODEL_SIZE), 0)
    end
end

-- Round up to 0.01 mm so a suggested minimum is never below the real one.
local function format_minimum(value)
    return ("%.2f"):format(math.ceil(value * 100 - 1e-6) / 100)
end

-- Checks the dialog values that do not depend on the QR content.
local function validate_dimensions(dimensions)
    local base_height = dimensions.base_height
    local pattern_height = dimensions.pattern_height
    validate_height(base_height, "Base plate height")
    validate_height(pattern_height, "Raised square height")
    if base_height + pattern_height > MAX_MODEL_SIZE then
        error("Base plate height and raised square height must add up to at most " .. MAX_MODEL_SIZE .. " mm.", 0)
    end

    local qr_size = dimensions.qr_size
    if not is_finite_positive_number(qr_size) or qr_size > MAX_MODEL_SIZE then
        error(("QR pattern size must be a positive number of at most %g mm."):format(MAX_MODEL_SIZE), 0)
    end

    -- A diameter of 0 means no keychain hole.
    local hole_diameter = dimensions.hole_diameter
    if hole_diameter == nil then
        hole_diameter = 0
    end
    if type(hole_diameter) ~= "number" or not (hole_diameter == 0
            or (hole_diameter >= MIN_HOLE_DIAMETER and hole_diameter <= MAX_HOLE_DIAMETER)) then
        error(("Keychain hole diameter must be 0 for no hole, or between %g and %g mm."):format(MIN_HOLE_DIAMETER, MAX_HOLE_DIAMETER), 0)
    end

    return {
        qr_size = qr_size + 0.0,
        base_height = base_height,
        pattern_height = pattern_height,
        borders = parse_borders(dimensions.border),
        hole_diameter = hole_diameter
    }
end

-- Computes the plate layout for a QR grid of matrix_size modules per side.
-- nozzle_diameter is optional; when present, each module must be at least that wide.
local function resolve_layout(spec, matrix_size, nozzle_diameter)
    local qr_size = spec.qr_size
    local module_size = qr_size / matrix_size

    local min_module_size = MIN_FEATURE_SIZE
    local limited_by_nozzle = nozzle_diameter ~= nil and nozzle_diameter > min_module_size
    if limited_by_nozzle then
        min_module_size = nozzle_diameter
    end
    local min_qr_size = matrix_size * min_module_size
    -- Allow for floating-point rounding when the size is exactly at the minimum.
    if qr_size + 1e-9 < min_qr_size then
        if limited_by_nozzle then
            error(("Each QR square would be %.2f mm wide, narrower than the %.2f mm nozzle. Set the QR pattern size to at least %s mm or shorten the content."):format(
                module_size, nozzle_diameter, format_minimum(min_qr_size)), 0)
        end
        error(("Increase the QR pattern size to at least %s mm for this QR code."):format(format_minimum(min_qr_size)), 0)
    end

    local quiet_zone = QUIET_ZONE_MODULES * module_size
    local function side_width(value)
        if value == AUTO_BORDER then
            return quiet_zone
        end
        return value
    end
    local borders = spec.borders
    local top = side_width(borders.top)
    local right = side_width(borders.right)
    local bottom = side_width(borders.bottom)
    local left = side_width(borders.left)

    local plate_width = qr_size + left + right
    local plate_height = qr_size + bottom + top
    if plate_width > MAX_MODEL_SIZE or plate_height > MAX_MODEL_SIZE then
        error("The QR pattern and borders must fit within " .. MAX_MODEL_SIZE .. " mm on each side of the plate.", 0)
    end

    return {
        module_size = module_size,
        plate_width = plate_width,
        plate_height = plate_height,
        border_left = left,
        border_bottom = bottom
    }
end

-- Returns the keychain tab centered above the plate from resolve_layout, or nil without a hole.
-- The tab is a round ring with the hole in its center, joined to the plate by a rectangular
-- bridge. Coordinates use the plate's lower-left corner as the origin.
local function resolve_keychain_tab(spec, layout)
    if spec.hole_diameter == 0 then
        return nil
    end
    local hole_radius = spec.hole_diameter / 2
    local outer_radius = hole_radius + math.max(MIN_TAB_WALL, spec.hole_diameter / 2)
    local height = layout.plate_height
    local overlap = math.min(TAB_OVERLAP, height)

    local center = { x = layout.plate_width / 2, y = height + outer_radius }
    local bridge = {
        x = center.x - outer_radius,
        y = height - overlap,
        width = 2 * outer_radius,
        height = outer_radius + overlap
    }

    -- The tab is centered and at most 60 mm wide, so only the added height can exceed the limit.
    if center.y + outer_radius > MAX_MODEL_SIZE then
        error("The plate and keychain tab must fit within " .. MAX_MODEL_SIZE .. " mm on each side. Use a smaller pattern, border, or hole.", 0)
    end

    return {
        center = center,
        outer_radius = outer_radius,
        hole_radius = hole_radius,
        bridge = bridge
    }
end

-- Returns the top Z of the first layer that contains only raised squares. PrusaSlicer slices
-- each layer at its middle, so this is the first layer whose middle lies above the base plate.
local function first_pattern_layer_z(base_height, pattern_height, layer_height, first_layer_height)
    local top = first_layer_height
    local height = first_layer_height
    while top - height / 2 <= base_height + 1e-6 do
        top = top + layer_height
        height = layer_height
    end
    if top - height / 2 >= base_height + pattern_height - 1e-6 then
        error(("The raised squares are too thin for %g mm layers. Increase the raised square height to at least %g mm."):format(
            layer_height, layer_height), 0)
    end
    return top
end

return {
    validate_dimensions = validate_dimensions,
    resolve_layout = resolve_layout,
    resolve_keychain_tab = resolve_keychain_tab,
    first_pattern_layer_z = first_pattern_layer_z
}
