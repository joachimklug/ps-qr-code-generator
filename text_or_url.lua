info = {
    id = "url",
    type = "project.plugin",
    title = "QR Code Generator - Text or URL",
    menu = "Generate-QR/Text or URL",
    params = {
        { name = "text",    label = "Text or URL",          type = "string", default = "https://example.com" },
        -- Shared dimension params. PrusaSlicer reads info before require is available, so these
        -- are copied into every command file. scripts/check_shared_params.lua keeps them in sync.
        { name = "qr_size", label = "QR pattern size (mm)", type = "float",  default = 80 },
        {
            name = "border",
            label = "Border: auto or mm (top, right, bottom, left)",
            type = "string",
            default = "auto"
        },
        { name = "base_height",    label = "Base plate height (mm)",    type = "float", default = 2 },
        { name = "pattern_height", label = "Raised square height (mm)", type = "float", default = 1 }
    }
}

local MAX_TEXT_BYTES = 1024

local function generate(opts)
    local text = opts.text
    if type(text) ~= "string" or text == "" or text:find("%c") then
        error("Enter text or a URL without control characters.", 0)
    end
    if #text > MAX_TEXT_BYTES then
        error("The text or URL must be at most " .. MAX_TEXT_BYTES .. " bytes.", 0)
    end

    require("lib/qr_plate").add_qr_plate(text, opts, "Could not encode the text or URL as a QR code.")
end

-- PrusaSlicer does not show errors from plugin commands, so lib/error_plate.lua shows them on the bed.
function execute(opts)
    require("lib/error_plate").run(generate, opts)
end
