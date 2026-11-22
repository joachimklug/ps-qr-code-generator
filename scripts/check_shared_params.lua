-- Checks that every QR command declares the same shared dimension params.
-- PrusaSlicer reads each command's info table before require is available, so the shared
-- params cannot live in lib/ and are copied into every command file instead.
--
-- Usage from the repository root: lua5.4 scripts/check_shared_params.lua ./*.lua

-- PrusaSlicer also loads .lua files in subfolders while discovering plugins. It passes no
-- command-line arguments, so stop quietly there.
if type(arg) ~= "table" then
    return
end

local SHARED_PARAMS = {
    "qr_size", "border", "base_height", "pattern_height", "two_color", "hole_diameter"
}

local function serialize(value)
    if type(value) ~= "table" then
        return type(value) .. ":" .. tostring(value)
    end
    local keys = {}
    for key in pairs(value) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)
    local parts = {}
    for _, key in ipairs(keys) do
        parts[#parts + 1] = tostring(key) .. "=" .. serialize(value[key])
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

-- Runs a command file in its own environment and returns its info table.
-- Command files only define info and execute at load time, so this has no side effects.
local function load_info(path)
    local env = setmetatable({}, { __index = _G })
    local chunk, load_error = loadfile(path, "t", env)
    if not chunk then
        error(load_error, 0)
    end
    chunk()
    if type(env.info) ~= "table" or type(env.info.params) ~= "table" then
        error(path .. ": info.params is missing", 0)
    end
    return env.info
end

if #arg == 0 then
    io.stderr:write("Usage: lua5.4 scripts/check_shared_params.lua <command files>\n")
    os.exit(2)
end

local failed = false
local reference, reference_path
for _, path in ipairs(arg) do
    local params = {}
    for _, param in ipairs(load_info(path).params) do
        params[param.name] = param
    end

    local signature = {}
    for _, name in ipairs(SHARED_PARAMS) do
        if params[name] == nil then
            print(path .. ": missing shared param " .. name)
            failed = true
        end
        signature[#signature + 1] = serialize(params[name])
    end
    signature = table.concat(signature, "\n")

    if reference == nil then
        reference, reference_path = signature, path
    elseif signature ~= reference then
        print(path .. ": shared params differ from " .. reference_path)
        failed = true
    end
end

if failed then
    os.exit(1)
end
print("Shared params match in " .. #arg .. " command files.")
