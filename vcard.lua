info = {
    id = "vcard",
    type = "project.plugin",
    title = "QR Code Generator - vCard",
    menu = "Generate-QR/vCard",
    params = {
        { name = "first_name",   label = "First name",           type = "string", default = "" },
        { name = "last_name",    label = "Last name",            type = "string", default = "" },
        { name = "organization", label = "Organization",        type = "string", default = "" },
        { name = "job_title",    label = "Job title",            type = "string", default = "" },
        { name = "phone",        label = "Phone number",         type = "string", default = "" },
        { name = "email",        label = "Email address",        type = "string", default = "" },
        { name = "website",      label = "Website URL",          type = "string", default = "" },
        { name = "qr_size",      label = "QR pattern size (mm)", type = "float",  default = 80 },
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

local MAX_VCARD_BYTES = 1024
local VCARD_SIZE_ERROR = "The vCard must be at most " .. MAX_VCARD_BYTES .. " bytes. Shorten the contact details."

local function read_contact_field(value, label)
    if value == nil then
        return ""
    end
    if type(value) ~= "string" or value:find("%c") then
        error(label .. " must be a single line of text without control characters.", 0)
    end
    if #value > MAX_VCARD_BYTES then
        error(VCARD_SIZE_ERROR, 0)
    end
    return value:match("^%s*(.-)%s*$")
end

local function escape_text(value)
    return (value:gsub([[([\\;,])]], "\\%1"))
end

local function append_text_property(lines, property, value)
    if value ~= "" then
        lines[#lines + 1] = property .. ":" .. escape_text(value)
    end
end

local function fold_line(line)
    local chunks = {}
    local start_index = 1
    local max_bytes = 75
    while #line - start_index + 1 > max_bytes do
        local next_start = start_index + max_bytes
        -- Move the fold before the character if it falls inside a UTF-8 sequence.
        for _ = 1, 3 do
            local next_byte = line:byte(next_start)
            if next_byte < 0x80 or next_byte >= 0xc0 then
                break
            end
            next_start = next_start - 1
        end
        chunks[#chunks + 1] = line:sub(start_index, next_start - 1)
        start_index = next_start
        max_bytes = 74
    end
    chunks[#chunks + 1] = line:sub(start_index)
    return table.concat(chunks, "\r\n ")
end

function execute(opts)
    local first_name = read_contact_field(opts.first_name, "First name")
    local last_name = read_contact_field(opts.last_name, "Last name")
    if first_name == "" and last_name == "" then
        error("Enter a first name or a last name.", 0)
    end

    local organization = read_contact_field(opts.organization, "Organization")
    local job_title = read_contact_field(opts.job_title, "Job title")
    local phone = read_contact_field(opts.phone, "Phone number")
    local email = read_contact_field(opts.email, "Email address")
    local website = read_contact_field(opts.website, "Website URL")

    if phone ~= "" and (not phone:match("^%+?[%d ().%-]+$") or not phone:find("%d")) then
        error("Enter a phone number with digits and an optional leading +.", 0)
    end
    if email ~= "" and not email:match("^[^%s@<>]+@[^%s@<>]+$") then
        error("Enter an email address such as name@example.com.", 0)
    end
    if website ~= "" and (not website:lower():match("^https?://[^/%?#]+") or website:find("[%s<>\"\\]")) then
        error("Enter a full website URL starting with http:// or https://.", 0)
    end

    local display_name = (first_name .. " " .. last_name):match("^%s*(.-)%s*$")
    local lines = {
        "BEGIN:VCARD",
        "VERSION:3.0",
        "N:" .. escape_text(last_name) .. ";" .. escape_text(first_name) .. ";;;",
        "FN:" .. escape_text(display_name)
    }
    append_text_property(lines, "ORG", organization)
    append_text_property(lines, "TITLE", job_title)
    append_text_property(lines, "TEL", phone)
    append_text_property(lines, "EMAIL", email)
    if website ~= "" then
        lines[#lines + 1] = "URL:" .. website
    end
    lines[#lines + 1] = "END:VCARD"

    for index, line in ipairs(lines) do
        lines[index] = fold_line(line)
    end
    local payload = table.concat(lines, "\r\n") .. "\r\n"
    if #payload > MAX_VCARD_BYTES then
        error(VCARD_SIZE_ERROR, 0)
    end

    require("lib/qr_plate").add_qr_plate(payload, opts, "Could not encode the contact details as a QR code.")
end
