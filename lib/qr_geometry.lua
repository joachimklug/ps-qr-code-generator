local function make_pattern_volumes(matrix, geometry)
    local volumes = {}
    local matrix_size = #matrix
    local module_size = geometry.module_size
    local border_left = geometry.border_left
    local border_bottom = geometry.border_bottom

    for row = 1, matrix_size do
        -- QR rows descend from the top, while the build plate's Y axis points up.
        local row_y = border_bottom + (matrix_size - row) * module_size
        local column = 1
        while column <= matrix_size do
            if matrix[column][row] > 0 then
                local first_column = column
                repeat
                    column = column + 1
                until column > matrix_size or matrix[column][row] <= 0

                local run_width = (column - first_column) * module_size
                volumes[#volumes + 1] = {
                    mesh = api.make_cube(run_width, module_size, geometry.pattern_height),
                    translate = {
                        x = border_left + (first_column - 1) * module_size,
                        y = row_y,
                        z = geometry.base_height
                    }
                }
            else
                column = column + 1
            end
        end
    end

    return volumes
end

return { make_pattern_volumes = make_pattern_volumes }
