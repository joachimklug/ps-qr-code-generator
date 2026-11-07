local function is_finite_positive_number(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

local BORDER_INPUT_ERROR = "Enter one nonnegative border value or four comma-separated values in top, right, bottom, left order. Use a decimal point for fractions."

local function parse_borders(border)
    if type(border) ~= "string" then
        error(BORDER_INPUT_ERROR, 0)
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

local function resolve_layout(dimensions)
    if not is_finite_positive_number(dimensions.base_height) then
        error("Base plate height must be a positive number.", 0)
    end
    if not is_finite_positive_number(dimensions.pattern_height) then
        error("Raised square height must be a positive number.", 0)
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
    if not is_finite_positive_number(plate_width) or not is_finite_positive_number(plate_height) then
        error("The QR pattern and borders must produce finite plate dimensions.", 0)
    end

    return {
        qr_size = qr_size,
        plate_width = plate_width,
        plate_height = plate_height,
        border_left = left,
        border_bottom = bottom
    }
end

return { resolve_layout = resolve_layout }
