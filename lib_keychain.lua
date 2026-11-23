-- Builds the keychain tab that lib_utils.lua resolve_keychain_tab lays out.
-- The tab is as thick as the base plate, so it stays below the raised squares and below the
-- color change layer. The hole is a negative volume because the API has no boolean subtraction.

-- The API docs don't say where a cylinder's origin is, so center each one by its bounding box.
local function centered_on(mesh, center)
    local bounds = mesh:bounds()
    return {
        x = center.x - (bounds.min_x + bounds.max_x) / 2,
        y = center.y - (bounds.min_y + bounds.max_y) / 2,
        z = -bounds.min_z
    }
end

local function make_tab_volumes(tab, base_height, pattern_height)
    local bridge = tab.bridge
    local ring = api.make_cylinder(tab.outer_radius, base_height)
    -- The hole runs the full model height, so it cuts cleanly through the top base layer.
    local hole = api.make_cylinder(tab.hole_radius, base_height + pattern_height)
    return {
        {
            mesh = api.make_cube(bridge.width, bridge.height, base_height),
            translate = { x = bridge.x, y = bridge.y, z = 0 }
        },
        { mesh = ring, translate = centered_on(ring, tab.center) },
        { mesh = hole, translate = centered_on(hole, tab.center), type = VolumeType.Negative }
    }
end

return { make_tab_volumes = make_tab_volumes }
