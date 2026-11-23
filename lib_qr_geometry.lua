-- PrusaSlicer 3.0.0-alpha14 aborts at 1,000 scene listeners. Each part adds a listener,
-- so leave room for the base plate and listeners already registered by PrusaSlicer.
local MAX_PATTERN_VOLUMES = 900

local function make_pattern_volumes(matrix, geometry)
    local rectangles = {}
    local previous_row_runs = {}
    local matrix_size = #matrix
    local module_size = geometry.module_size
    local border_left = geometry.border_left
    local border_bottom = geometry.border_bottom

    for row = 1, matrix_size do
        local current_row_runs = {}
        local column = 1
        while column <= matrix_size do
            if matrix[column][row] > 0 then
                local first_column = column
                repeat
                    column = column + 1
                until column > matrix_size or matrix[column][row] <= 0

                local column_count = column - first_column
                local rectangle = previous_row_runs[first_column]
                if rectangle and rectangle.column_count == column_count then
                    rectangle.last_row = row
                else
                    if #rectangles == MAX_PATTERN_VOLUMES then
                        error("The QR code exceeds the " .. MAX_PATTERN_VOLUMES .. "-part limit. Shorten the QR content.", 0)
                    end
                    rectangle = {
                        first_column = first_column,
                        column_count = column_count,
                        first_row = row,
                        last_row = row
                    }
                    rectangles[#rectangles + 1] = rectangle
                end
                current_row_runs[first_column] = rectangle
            else
                column = column + 1
            end
        end
        previous_row_runs = current_row_runs
    end

    local volumes = {}
    for index, rectangle in ipairs(rectangles) do
        local width = rectangle.column_count * module_size
        local height = (rectangle.last_row - rectangle.first_row + 1) * module_size
        -- QR rows descend from the top, while the build plate's Y axis points up.
        local y = border_bottom + (matrix_size - rectangle.last_row) * module_size
        volumes[index] = {
            mesh = api.make_cube(width, height, geometry.pattern_height),
            translate = {
                x = border_left + (rectangle.first_column - 1) * module_size,
                y = y,
                z = geometry.base_height
            }
        }
    end
    return volumes
end

return { make_pattern_volumes = make_pattern_volumes }
