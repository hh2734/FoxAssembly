local sys_lib = {}

unpack = unpack or table.unpack
local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert
local pairs = pairs

local function err(text)
	print(text)
	if os then os.exit() else error() end
end


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

sys_lib.split = split

local function table_path(path_parts, start_table, last)
    local current = start_table or _G
    for i = 1, #path_parts do
        local part = path_parts[i]
        if current[part] == nil then
            current[part] = {}
        elseif type(current[part]) ~= "table" then
            current[part] = {}
        end
	if i == #path_parts and last then
	    current[part] = last
	end
        current = current[part]
    end
    return current
end

sys_lib.table_path = table_path

function sys_lib.import(name)
	local msg = "\n\nimport() failure\n"..name..[[: - Package not found!]].."\n"..[[Add '["]]..name..[["] = {">=", 1.0}' to _config.deps!]].."\n"
	local text = FoxRAM.read("packages/"..name)
	if text == false then err(msg) end
	--print(sys_lib)
	local ok, module = pcall(load(text), sys_lib)
	if ok then 
		local arr = split(name, "%.")
		table_path(arr, nil, module)
	else
		err("\n"..module)
	end
end

local sys_lib = {}

unpack = unpack or table.unpack
local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert
local pairs = pairs

local function err(text)
	print(text)
	if os then os.exit() else error() end
end


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

sys_lib.split = split

local function table_path(path_parts, start_table, last)
    local current = start_table or _G
    for i = 1, #path_parts do
        local part = path_parts[i]
        if current[part] == nil then
            current[part] = {}
        elseif type(current[part]) ~= "table" then
            current[part] = {}
        end
	if i == #path_parts and last then
	    current[part] = last
	end
        current = current[part]
    end
    return current
end

sys_lib.table_path = table_path

function sys_lib.import(name)
	local msg = "\n\nimport() failure\n"..name..[[: - Package not found!]].."\n"..[[Add '["]]..name..[["] = {">=", 1.0}' to _config.deps!]].."\n"
	local text = FoxRAM.read("packages/"..name)
	if text == false then err(msg) end
	--print(sys_lib)
	local ok, module = pcall(load(text), sys_lib)
	if ok then 
		local arr = split(name, "%.")
		table_path(arr, nil, module)
	else
		err("\n"..module)
	end
end

function sys_lib.load(path, name)
	local a, b, c = pcall(require, path.."/"..name)
	--print("'"..c.."'")
	if not c then c = true  end
	return b, a, c
end
function sys_lib.printr(...)
	print(unpack({...}))
	return unpack({...})
end

function sys_lib.safeload(text, nil_env, args)
	args = args or {}
	if nil_env then return pcall(load(text, nil, "bt", {}), unpack(args)) end
	return pcall(load(text), unpack(args))
end

return sys_lib
