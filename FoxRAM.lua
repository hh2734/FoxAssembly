local FoxRAM = {}
local ram = {[""] = {type = "folder", stat = "const"}}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert
local pairs = pairs

local function split(str, delimiter)
    if type(str) ~= "string" then return {} end
    delimiter = delimiter or "%s"
    
    local result = {}
    local pattern = string_format("([^%s]+)", delimiter)
    
    for match in str:gmatch(pattern) do
        table_insert(result, match)
    end
    return result
end

local function contains(value, ...)
    for i, val in ipairs({...}) do
        if value == val then
            return true, i
        end
    end
    return false
end

local function remove_trailing_elements(path_parts, count)
    count = count or 0
    if #path_parts - count <= 0 then
        return table_concat(path_parts), true
    end
    
    local result = {}
    for i = 1, #path_parts - count do
        result[i] = path_parts[i]
    end
    return table_concat(result, "/")
end

local function path_exists(addr)
    return ram[addr] ~= nil
end

local function validate_data(data)
    if not data then return false end
    
    data.type = data.type or ""
    data.stat = data.stat or ""
    data.text = tostring(data.text or "")
    
    local valid_types = contains(data.type, "file", "folder")
    local valid_stats = contains(data.stat, "const", "norm")
    
    return valid_types and valid_stats
end

local function parent_directory_exists(addr)
    local path_parts = split(addr, "/")
    local parent_path = remove_trailing_elements(path_parts, 1)
    
    if parent_path == addr then
        return true
    end
    
    local parent = ram[parent_path]
    return parent and parent.type == "folder"
end

local function new(addr, data)
    if not addr or type(addr) ~= "string" or not validate_data(data) then
        return false, "invalid arguments"
    end
    
    if path_exists(addr) then
        return false, "path already exists"
    end
    
    if not parent_directory_exists(addr) then
        return false, "parent directory does not exist"
    end
    
    ram[addr] = {
        type = data.type,
        stat = data.stat,
        text = data.text
    }
    
    return true
end

function FoxRAM.file(name, text, is_const)
    if type(name) ~= "string" or name == "" then
        return false, "invalid filename"
    end
    
    local stat = is_const and "const" or "norm"
    return new(name, {
        type = "file",
        stat = stat,
        text = text or ""
    })
end

function FoxRAM.folder(name, is_const)
    if type(name) ~= "string" or name == "" then
        return false, "invalid folder name"
    end
    
    local stat = is_const and "const" or "norm"
    return new(name, {
        type = "folder",
        stat = stat,
        text = ""
    })
end

function FoxRAM.read(addr)
    if type(addr) ~= "string" then
        return false, "invalid path"
    end
    
    local item = ram[addr]
    if not item or item.type ~= "file" then
        return false, "file not found or not a file"
    end
    
    return item.text
end

function FoxRAM.remove(addr)
    if type(addr) ~= "string" then
        return false, "invalid path"
    end
    
    local item = ram[addr]
    if not item or item.stat == "const" then
        return false, "cannot remove item"
    end
    
    ram[addr] = nil
    return true
end

function FoxRAM.exists(addr)
    return path_exists(addr)
end

function FoxRAM.get_type(addr)
    local item = ram[addr]
    return item and item.type or nil
end

function FoxRAM.list(prefix)
    prefix = prefix or ""
    local results = {}
    
    for path, item in pairs(ram) do
        if path:sub(1, #prefix) == prefix and path ~= prefix then
            table_insert(results, path)
        end
    end
    
    return results
end

return FoxRAM