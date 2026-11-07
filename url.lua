info = {
    id = "url",
    type = "project.plugin",
    title = "QR Code Generator - URL",
    menu = "Generate-QR/URL",
    params = {
        { name = "url",            label = "URL",                                 type = "string", default = "https://example.com" },
        { name = "plate_size",     label = "Total QR size including border (mm)", type = "float",  default = 90 },
        { name = "base_height",    label = "Base plate height (mm)",              type = "float",  default = 2 },
        { name = "pattern_height", label = "Raised square height (mm)",           type = "float",  default = 1 },
        { name = "border",         label = "Border width per side (mm)",          type = "float",  default = 5 }
    }
}

local MAX_URL_BYTES = 1024

function execute(opts)
    -- PrusaSlicer provides require when running the plugin, after metadata discovery.
    -- Vendored encoder from speedata/luaqrcode at 5a9c34bc04d5113048df8528af72ef31d25b7300.
    local encoder = require("qrencode")
    local qr_geometry = require("qr_geometry")
    local utils = require("utils")

    local url = opts.url
    if type(url) ~= "string" or url == "" or url:find("[%s%c]") then
        error("Enter a URL without spaces or control characters.", 0)
    end
    if #url > MAX_URL_BYTES then
        error("The URL must be at most " .. MAX_URL_BYTES .. " bytes.", 0)
    end

    utils.validate_dimensions(opts)

    local ran, encoded, matrix = pcall(encoder.qrcode, url)
    if not ran or not encoded then
        error("Could not encode the URL as a QR code.", 0)
    end

    local pattern_size = opts.plate_size - opts.border - opts.border
    local module_size = pattern_size / #matrix
    if module_size <= 0 then
        error("Total QR size leaves too little space for the QR pattern.", 0)
    end

    api.project:add_object {
        mesh = api.make_cube(opts.plate_size, opts.plate_size, opts.base_height),
        other_volumes = qr_geometry.make_pattern_volumes(matrix, {
            module_size = module_size,
            border_width = opts.border,
            base_height = opts.base_height,
            pattern_height = opts.pattern_height
        })
    }
end
