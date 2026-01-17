-- Error in library: fxas.lib.tocu >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768606455
-- DocType version: Beta X1
-- 2024, Raymond-foxdev ^w^
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.lib.tocu", -- Your package name
	version = 1.0, -- fxas.lib.tocu version
	deps = nil
}
--> ============   CONFIG   ============ <--


syslib = ...
if type(syslib) ~= "table" then
	return Box
end

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--

local function toHex(str)
	local hexStr = ""
	for i = 1, #str do
		local char = str:sub(i,i)
		hexStr = hexStr .. string.format("%02X", string.byte(char))
	end
	return hexStr
end

local function fromHex(hexStr)
	local str = ""
	for i = 1, #hexStr, 2 do
		local byte = tonumber(hexStr:sub(i,i+1), 16)
		str = str .. string.char(byte)
	end
	return str
end

local function hexToRGB(hex)
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)
	return r, g, b
end

local function rgbToAnsi(r, g, b)
	return string.format("\27[38;2;%d;%d;%dm", r, g, b)
end

local function rgb(text, hex)
	if not hex then return text end
	local r, g, b = hexToRGB(hex)
	local ansiCode = rgbToAnsi(r, g, b)
	return ansiCode .. text .. "\27[0m"
end

local function wait(seconds)
	local t = os.time()+tonumber(seconds)
	repeat until t <= os.time()
end

function Box.wait(sec)
	wait(sec)
end

function Box.colored(text, hex)
	local r, g, b = hexToRGB(hex)
	local ansiCode = rgbToAnsi(r, g, b)
	io.write(ansiCode .. text .. "\27[0m")
end

local function getos()
	if jit then
		return jit.os
	end
	local fh, err = assert(io.popen("uname -s 2>/dev/null", "r"))
	if fh then
		osname = fh:read()
	end
	return osname or "Windows"
end

local sys = getos()
local package_debug = false

local function clear()
	if sys == "Windows" then
		os.execute("cls")
	else
		os.execute("clear")
	end
end

local function choise(elements, input, char_mode)
	local index = 0
	local ind
	local width = 0
	local debug_text = ""
	for _, el in pairs(elements) do
		if utf8.len(el.title) > width then
			width = utf8.len(el.title)
		end
	end

	for _, element in pairs(elements) do
		index = index + 1
		if not char_mode then
			ind = index .. ". "
		else
			ind = element.key .. ": "
		end
		if package_debug then
			debug_text = " type="..element.type.."; name='"..element.name.."'; key='"..element.key.."'; exec="..tostring(element.exec)
		end

		local name = element.title
		if utf8.len(element.title) < width then
			repeat
				name = name .. " "
			until utf8.len(name) == width
		end

		if element.type == "menu" then
			print(ind .. name .. "  [#]"..debug_text)
		elseif element.type == "button" then
			print(ind .. name .. "  [*]"..debug_text)
		elseif element.type == "switch" then
			local state = element.state and "[+]" or "[-]"
			print(ind .. name .. "  " .. state..debug_text)
		elseif element.type == "multiswitch" then
			local state = element.state
			print(ind .. name .. "  [" .. state .. "]" .. debug_text)
		elseif element.type == "counter" then
			local state = element.state
			print(ind .. name .. "  [" .. state .. "]  [" .. element.min .. "-" .. element.max .. "]" .. debug_text)
		end
	end
	io.write("\n" .. input)
	local result = io.read()
	return result
end

local function menu(element)
	if element.color then
		print(rgb(element.title, element.color).."\n")
	else
		print(element.title .. "\n")
	end
	print("!. debug")
	print("0. " .. element.ret)
	
	for index, el in ipairs(element.elements) do
		el.title = rgb(el.title, titleColor)
	end

	local opt = choise(element.elements, element.input, element.char_mode)
	return opt
end

local function switch(element)
	element.state = not element.state
	return element
end

local function button(element)
	
end

local function multiswitch(element)
	print("\n" .. element.title)
	for i, variant in ipairs(element.variants) do
		local selected = (i == element.state) and ">" or " "
		print("  " .. selected .. i .. ". " .. variant)
	end
	io.write("\n" .. element.input)
	local opt = io.read()
	local var = tonumber(opt) or 1
	element.state = var
	return element
end

local function counter(element)
	print("\n" .. element.title)
	io.write("\n" .. element.input)
	local opt = io.read()
	local var = tonumber(opt) or element.min
	print(var)
	if var >= element.min and var <= element.max then
		element.state = var
	else
		element.state = element.state
	end
	return element
end

function Box.ui(ui)
	clear()
	local opt = menu(ui)
	if opt == "!" then package_debug = not package_debug end
	if not ui.char_mode then
		opt = tonumber(opt)
	end

	if opt == 0 or opt == "0" then return ui, nil end
	local element = ui.elements[opt]
	if element then
		local el_type = element.type
		if type(element.exec) == "function" then
			element.exec()
		elseif type(element.exec) == "string" then
			load(fromHex(element.exec))()
		end
		local c = true
		if el_type == "menu" then
			while c do
				element, c = Box.ui(element)
			end
		elseif el_type == "button" then
			button(element)
		elseif el_type == "switch" then
			ui.elements[opt] = switch(element)
		elseif el_type == "multiswitch" then
			ui.elements[opt] = multiswitch(element)
		elseif el_type == "counter" then
			ui.elements[opt] = counter(element)
		end
	end
	return ui, true
end

function Box.remove(ui, name)
	for index, element in ipairs(ui.elements) do
		if element.name == name then
			table.remove(ui.elements, index)
			return ui, true
		end
	end
	return ui, true
end

function Box.exists(path)
	local f = io.open(path)
	if f then f:close() return true end
	return false
end

function Box.input(inp)
	io.write(inp)
	local text = io.read()
	return text
end

local szt = {}

local function char(c) return ("\\%3d"):format(c:byte()) end
local function szstr(s) return ('"%s"'):format(s:gsub("[^ !#-~]", char)) end
local function szfun(f) return '"'..toHex(string.dump(f))..'"' end
local function szany(...) return szt[type(...)](...) end

local function sztbl(t,code,var)
	for k,v in pairs(t) do
		local ks = szany(k,code,var)
		local vs = szany(v,code,var)
		code[#code+1] = ("%s[%s]=%s"):format(var[t],ks,vs)
	end
	return "{}"
end

local function memo(sz)
	return function(d,code,var)
		if var[d] == nil then
			var[1] = var[1] + 1
			var[d] = ("_[%d]"):format(var[1])
			local index = #code+1
			code[index] = ""
			code[index] = ("%s=%s"):format(var[d],sz(d,code,var))
		end
		return var[d]
	end
end

szt["nil"]	  = tostring
szt["boolean"]  = tostring
szt["number"]   = tostring
szt["string"]   = szstr
szt["function"] = memo(szfun)
szt["table"]	= memo(sztbl)

local function serialize(d)
	local code = { "local _ = {}" }
	local value = szany(d,code,{0})
	code[#code+1] = "return "..value
	if #code == 2 then return code[2]
	else return table.concat(code, "\n")
	end
end

function Box.sas(ui)
	local str = serialize(ui)
	return str
end

function Box.save(path, ui)
	local save = io.open(path, "w")
	save:write(serialize(ui))
	save:close()
	return true
end

function Box.clear()
	clear()
end

function Box.hex(text)
	return toHex(text)
end

function Box.dehex(hex)
	return fromHex(hex)
end

return Box
