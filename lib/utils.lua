local function is_finite_positive_number(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

local function validate_dimensions(dimensions)
    local plate_size = dimensions.plate_size
    if not is_finite_positive_number(plate_size) then
        error("Total QR size must be a positive number.", 0)
    end
    if not is_finite_positive_number(dimensions.base_height) then
        error("Base plate height must be a positive number.", 0)
    end
    if not is_finite_positive_number(dimensions.pattern_height) then
        error("Raised square height must be a positive number.", 0)
    end
    local border = dimensions.border
    if border ~= 0 and not is_finite_positive_number(border) then
        error("Border width must be zero or a positive number.", 0)
    end
    if border >= plate_size - border then
        error("Border width per side must be less than half the total QR size.", 0)
    end
end

return { validate_dimensions = validate_dimensions }
