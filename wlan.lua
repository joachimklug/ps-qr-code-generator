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
        { name = "qr_size",  label = "QR pattern size (mm)",                  type = "float",  default = 80 },
        {
            name = "border",
            label = "Border (top, right, bottom, left)",
            type = "string",
            default = "5"
        },
        { name = "base_height",    label = "Base plate height (mm)",    type = "float", default = 2 },
        { name = "pattern_height", label = "Raised square height (mm)", type = "float", default = 1 }
    }
}

local security_types = {
    ["WPA/WPA2 Personal"] = "WPA",
    ["WPA3 Personal"] = "SAE",
    WEP = "WEP",
    Open = "nopass"
}

local function encode_wifi_value(value, is_raw_key)
    -- Some readers interpret unquoted hexadecimal values as bytes rather than text.
    if not is_raw_key and value:match("^%x+$") then
        return '"' .. value .. '"'
    end
    return (value:gsub([[([\;,:"])]], "\\%1"))
end

local function encode_password(password, security)
    if type(password) ~= "string" or password == "" or password:find("%c") then
        error("Enter a Wi-Fi password without control characters.", 0)
    end

    local length = #password
    if length > 1024 then
        error("The Wi-Fi password must be at most 1024 bytes.", 0)
    end

    local is_raw_key = false
    if security == "WPA" then
        is_raw_key = length == 64 and password:match("^%x+$") ~= nil
        if not is_raw_key and (length < 8 or length > 63) then
            error("Enter a WPA/WPA2 password of 8 to 63 bytes or a 64-digit hexadecimal key.", 0)
        end
    elseif security == "WEP" then
        is_raw_key = (length == 10 or length == 26 or length == 58) and password:match("^%x+$") ~= nil
        if not is_raw_key and length ~= 5 and length ~= 13 and length ~= 29 then
            error("Enter a WEP key of 5, 13, or 29 bytes, or 10, 26, or 58 hexadecimal digits.", 0)
        end
    end

    return encode_wifi_value(password, is_raw_key)
end

function execute(opts)
    local ssid = opts.ssid
    if type(ssid) ~= "string" or ssid == "" or #ssid > 32 or ssid:find("%c") then
        error("Enter a network name of 1 to 32 bytes without control characters.", 0)
    end

    local security = security_types[opts.security]
    if not security then
        error("Select a Wi-Fi security type.", 0)
    end

    local payload = "WIFI:T:" .. security .. ";S:" .. encode_wifi_value(ssid) .. ";"
    if security ~= "nopass" then
        payload = payload .. "P:" .. encode_password(opts.password, security) .. ";"
    end
    if opts.hidden == true then
        payload = payload .. "H:true;"
    end

    require("lib/qr_plate").add_qr_plate(payload .. ";", opts, "Could not encode the Wi-Fi settings as a QR code.")
end
