local MIN_FEATURE_SIZE = 0.01
local MAX_MODEL_SIZE = 1000
local MAX_BORDER_BYTES = 256

local function is_finite_positive_number(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

local BORDER_INPUT_ERROR = "Enter one nonnegative border value or four comma-separated values in top, right, bottom, left order. Use a decimal point for fractions."

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
        local decimal = field:match("^%s*(%d*%.?%d*)%s*$")
        local width = decimal and tonumber(decimal)
        if (width ~= 0 and not is_finite_positive_number(width)) or #borders == 4 then
            error(BORDER_INPUT_ERROR, 0)
        end
        -- Keep plate dimension sums in floating point even for whole millimeters.
        borders[#borders + 1] = width + 0.0
    end

    if #borders == 1 then
        local width = borders[1]
        return width, width, width, width
    end
    if #borders ~= 4 then
        error(BORDER_INPUT_ERROR, 0)
    end
    return table.unpack(borders)
end

local function validate_height(value, label)
    if type(value) ~= "number" or not (value >= MIN_FEATURE_SIZE and value <= MAX_MODEL_SIZE) then
        error(("%s must be between %g and %g mm."):format(label, MIN_FEATURE_SIZE, MAX_MODEL_SIZE), 0)
    end
end

local function resolve_layout(dimensions)
    local base_height = dimensions.base_height
    local pattern_height = dimensions.pattern_height
    validate_height(base_height, "Base plate height")
    validate_height(pattern_height, "Raised square height")
    if base_height + pattern_height > MAX_MODEL_SIZE then
        error("Base plate height and raised square height must add up to at most " .. MAX_MODEL_SIZE .. " mm.", 0)
    end

    local qr_size = dimensions.qr_size
    local legacy_plate_size
    local top, right, bottom, left
    if qr_size == nil and dimensions.plate_size ~= nil then
        legacy_plate_size = dimensions.plate_size
        local border = dimensions.border
        if not is_finite_positive_number(legacy_plate_size) then
            error("Total QR size must be a positive number.", 0)
        end
        if border ~= 0 and not is_finite_positive_number(border) then
            error("Border width must be zero or a positive number.", 0)
        end
        if border >= legacy_plate_size - border then
            error("Border width per side must be less than half the total QR size.", 0)
        end
        qr_size = legacy_plate_size - border - border
        top, right, bottom, left = border, border, border, border
    else
        top, right, bottom, left = parse_borders(dimensions.border)
    end
    if not is_finite_positive_number(qr_size) then
        error("QR pattern size must be a positive number.", 0)
    end

    local plate_width = legacy_plate_size or (qr_size + left + right)
    local plate_height = legacy_plate_size or (qr_size + bottom + top)
    if plate_width > MAX_MODEL_SIZE or plate_height > MAX_MODEL_SIZE then
        error("The QR pattern and borders must fit within " .. MAX_MODEL_SIZE .. " mm on each side of the plate.", 0)
    end

    return {
        qr_size = qr_size,
        plate_width = plate_width,
        plate_height = plate_height,
        border_left = left,
        border_bottom = bottom
    }
end

return { resolve_layout = resolve_layout, MIN_FEATURE_SIZE = MIN_FEATURE_SIZE }
