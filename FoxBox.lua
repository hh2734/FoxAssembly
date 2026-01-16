-- Error in app: fxas.foxbox.app >
-- FoxBox version: 2.0
-- fox.lua version: 1.0
-- Unix time: 1768579679
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


_config = {
	package = "fxas.foxbox.app",
	version = 2.1,
	path = arg[0]:gsub("FoxBox.lua$","").."FoxAssembly",
	deps = nil
}
--> ============   CONFIG   ============ <--


	_PATH = arg[0]:gsub("/FoxBox.lua$","")
	_config.path = _PATH and _PATH or _config.path
	_PATH = nil

--> ============    PATH    ============ <--


-->      Path to FoxAssembly folder      <--

	Fox = require(_config.path..".fox")

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--


local function mc(arg1, ...)
	for k, v in pairs({...}) do if arg1 == v then return true end end
	return false
end

local DocType_VERSION = "Beta X1"

local op = arg[1]
local pkg = arg[#arg]

local dummy_lib = [[
-- Error in library: %s >
-- FoxBox version: %s
-- fox.lua version: %s
-- Unix time: %d
-- DocType version: %s
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "%s", -- Your package name
	version = 1.0, -- %s version
	deps = {
		["com.package.name"] = {">=", 1.0}
	}
	-- Modes: >=, <=, >, <, ==, ~=
	-- You can mix different modes:
	-- {{">=", 1.0}, {"<", 2.3}, {"~=", 1.58}, ...}
	-- Or 'deps = nil' if none
}
--> ============   CONFIG   ============ <--


syslib = ...
if type(syslib) ~= "table" then
	return Box
end

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--





return Box
]]

local dummy_app = [[
-- Error in app: %s >
-- FoxBox version: %s
-- fox.lua version: %s
-- Unix time: %d
-- DocType version: %s
--> ============  METADATA  ============ <--


_config = {
	package = "%s", -- Your package name
	version = 1.0, -- %s version
	path = arg[0]:gsub("%s.lua$","").."FoxAssembly",
	deps = {
		["com.package.name"] = {">=", 1.0}
	}
	-- Modes: >=, <=, >, <, ==, ~=
	-- You can mix different modes:
	-- {{">=", 1.0}, {"<", 2.3}, {"~=", 1.58}, ...}
	-- Or 'deps = nil' if none
}
--> ============   CONFIG   ============ <--


	_PATH = nil -- CUSTOM PATH (must be string)

	_config.path = _PATH and _PATH or _config.path
	_PATH = nil

--> ============    PATH    ============ <--


-->      Path to FoxAssembly folder      <--

	Fox = require(_config.path..".fox")

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--





return 1
]]


local function err() print("Wrong package name!") end

if mc(op, "new", "-n") then
	if not pkg then return err() end
	local str = "abcdefghijklmnopqrstuvwxyz0123456789"
	local dot = false
	local is_err = false
	for i = 1, #pkg do
		local let = pkg:sub(i, i)
		if let == "%." then
			if dot then
				return err()
			end
			dot = true
			return
		elseif not str:find(let) then
			return err()
		else
			if dot and let:find("%d") then return err() end
			dot = false
		end
	end
	if not pkg:find("%.") then return err() end
	if pkg:sub(-1, -1) == "%." then return err() end
	local kw = "and break do else elseif end false for function if in local nil not or repeat return then true until while goto"
	for keyword in kw:gmatch("%a+") do if pkg:find("%A"..keyword.."%A") then end end
	if pkg:sub(1, 5) == "self." then return err() end
	local is_dev
	for k, v in pairs(arg) do if mc(v, "-d", "dev") then is_dev = true end end
	if pkg:sub(1, 5) == "fxas." and not is_dev then return print("'fxas.' is reserved!") end
	local is_app
	for k, v in pairs(arg) do if mc(v, "-a", "app") then is_app = true end end
	local pth = is_app and _config.path:gsub("FoxAssembly$", "")..pkg:gsub("%.", "_")..".lua" or _config.path.."/Boxes/"..pkg:gsub("%.", "_")..".lua"
	local f = io.open(pth, "a+b")
	if f == nil then return err() end
	local t = f:read("*a")
	if t ~= "" and t then return print("Can't overwrite package!") end
	local time = 0
	if os then time = os.time() end
	local dummy_pkg = is_app and dummy_app or dummy_lib
	f:write(is_app and dummy_pkg:format(pkg, tostring(_config.version), tostring(Fox._VERSION), time, DocType_VERSION, pkg, pkg, pkg) or dummy_pkg:format(pkg, tostring(_config.version), tostring(Fox._VERSION), time, DocType_VERSION, pkg, pkg))
	f:close()
	print("Success!")
elseif mc(op, "remove", "-r", "rm") then
	if not pkg then return err() end
	if not pkg:find("%.") then return err() end
	local str = "abcdefghijklmnopqrstuvwxyz0123456789"
	local dot = false
	local is_err = false
	for i = 1, #pkg do
		local let = pkg:sub(i, i)
		if let == "%." then
			if dot then
				return err()
			end
			dot = true
			return
		elseif not str:find(let) then
			return err()
		else
			if dot and let:find("%d") then return err() end
			dot = false
		end
	end
	if pkg:sub(-1, -1) == "%." then return err() end
	local is_dev
	for k, v in pairs(arg) do if mc(v, "-d", "dev") then is_dev = true end end
	if pkg:sub(1, 5) == "fxas." and not is_dev then return print("'fxas.' is reserved!") end
	if os then
		if not os.remove(_config.path.."/packages/"..pkg:gsub("%.", "_")..".lua") then
			return print("Package "..pkg.." is not installed!")
		end
		return print("Success!")
	else
		return print("Can't find os library!\nPlease, delete "..pkg.." manually!")
	end
else
	print("\nWrong argument!\n")
	print("Usage:\nlua path/to/FoxAssembly/FoxBox.lua [install (SOON), remove (-r, -rm), new (-n)] [-a, app -> app] com.package.name ('fxas.' is reserved)")
end


return 1
