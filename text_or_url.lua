info = {
    id = "url",
    type = "project.plugin",
    title = "QR Code Generator - Text or URL",
    menu = "Generate-QR/Text or URL",
    params = {
        { name = "text",           label = "Text or URL",                         type = "string", default = "https://example.com" },
        { name = "plate_size",     label = "Total QR size including border (mm)", type = "float",  default = 90 },
        { name = "base_height",    label = "Base plate height (mm)",              type = "float",  default = 2 },
        { name = "pattern_height", label = "Raised square height (mm)",           type = "float",  default = 1 },
        { name = "border",         label = "Border width per side (mm)",          type = "float",  default = 5 }
    }
}

local MAX_TEXT_BYTES = 1024

function execute(opts)
    local text = opts.text
    if type(text) ~= "string" or text == "" or text:find("%c") then
        error("Enter text or a URL without control characters.", 0)
    end
    if #text > MAX_TEXT_BYTES then
        error("The text or URL must be at most " .. MAX_TEXT_BYTES .. " bytes.", 0)
    end

    require("lib/qr_plate").add_qr_plate(text, opts, "Could not encode the text or URL as a QR code.")
end
