info = {
    id = "wlan",
    type = "project.plugin",
    title = "QR Code Generator - Wi-Fi",
    menu = "Generate-QR/Wi-Fi",
    params = {
        { name = "ssid",     label = "Network name (SSID)",                   type = "string", default = "" },
        {
            name = "security",
            label = "Security",
            type = "combobox",
            allowed_values = { "WPA/WPA2 Personal", "WPA3 Personal", "WEP", "Open" }
        },
        { name = "password", label = "Wi-Fi password (leave blank for Open)", type = "string", default = "" },
        { name = "hidden",   label = "Hidden network",                        type = "bool",   default = false },
        -- Shared dimension params. PrusaSlicer reads info before require is available, so these
        -- are copied into every command file. scripts/check_shared_params.lua keeps them in sync.
        { name = "qr_size",  label = "QR pattern size (mm)",                  type = "float",  default = 80 },
        {
            name = "border",
            label = "Border: auto or mm (top, right, bottom, left)",
            type = "string",
            default = "auto"
        },
        { name = "base_height",    label = "Base plate height (mm)",    type = "float", default = 2 },
        { name = "pattern_height", label = "Raised square height (mm)", type = "float", default = 1 },
        {
            name = "two_color",
            label = "Two colors",
            type = "combobox",
            allowed_values = { "Two colors: off", "Two colors: color change (one nozzle)", "Two colors: second tool (multi-tool)" }
        }
    }
}

-- WPA3 is encoded as T:WPA because every common scanner understands it, and it also covers
-- WPA2/WPA3 transition networks. The password rules still follow the selected type.
local security_types = {
    ["WPA/WPA2 Personal"] = { code = "WPA", password_rules = "WPA" },
    ["WPA3 Personal"] = { code = "WPA", password_rules = "WPA3" },
    WEP = { code = "WEP", password_rules = "WEP" },
    Open = { code = "nopass" }
}

-- Escape the characters the WIFI: format reserves. Values are never wrapped in quotes:
-- some scanners keep the quotes as part of the value, current iOS and Android scanners read
-- SSIDs as text, and the length rules below keep a passphrase from looking like a raw hex key.
local function escape_wifi_value(value)
    return (value:gsub([[([\;,:"])]], "\\%1"))
end

local function encode_password(password, rules)
    if type(password) ~= "string" or password == "" or password:find("%c") then
        error("Enter a Wi-Fi password without control characters.", 0)
    end

    local length = #password
    if length > 1024 then
        error("The Wi-Fi password must be at most 1024 bytes.", 0)
    end

    local is_hex = password:match("^%x+$") ~= nil
    if rules == "WPA" then
        if not (length == 64 and is_hex) and (length < 8 or length > 63) then
            error("Enter a WPA/WPA2 password of 8 to 63 bytes or a 64-digit hexadecimal key.", 0)
        end
    elseif rules == "WPA3" then
        -- WPA3 has no raw keys, but scanners read 64 hex digits after T:WPA as one.
        if length == 64 and is_hex then
            error("Scanners read a WPA3 password of exactly 64 hexadecimal digits as a raw WPA key. Use a different password.", 0)
        end
    elseif rules == "WEP" then
        local is_hex_key = (length == 10 or length == 26 or length == 58) and is_hex
        if not is_hex_key and length ~= 5 and length ~= 13 and length ~= 29 then
            error("Enter a WEP key of 5, 13, or 29 bytes, or 10, 26, or 58 hexadecimal digits.", 0)
        end
    end

    return escape_wifi_value(password)
end

local function generate(opts)
    local ssid = opts.ssid
    if type(ssid) ~= "string" or ssid == "" or #ssid > 32 or ssid:find("%c") then
        error("Enter a network name of 1 to 32 bytes without control characters.", 0)
    end

    local security = security_types[opts.security]
    if not security then
        error("Select a Wi-Fi security type.", 0)
    end

    local payload = "WIFI:T:" .. security.code .. ";S:" .. escape_wifi_value(ssid) .. ";"
    if security.password_rules then
        payload = payload .. "P:" .. encode_password(opts.password, security.password_rules) .. ";"
    end
    if opts.hidden == true then
        payload = payload .. "H:true;"
    end

    require("lib/qr_plate").add_qr_plate(payload .. ";", opts, "Could not encode the Wi-Fi settings as a QR code.")
end

-- PrusaSlicer does not show errors from plugin commands, so lib/error_plate.lua shows them on the bed.
function execute(opts)
    require("lib/error_plate").run(generate, opts)
end
