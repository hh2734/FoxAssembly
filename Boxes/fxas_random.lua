-- Error in library: fxas.random >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768679878
-- DocType version: Beta X1
-- Raymond-foxdev, 2026
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.random", -- Your package name
	version = 1.0, -- fxas.random version
	deps = {
		["fxas.crypto.aes"] = {">=", 1.0}
	}
}
--> ============   CONFIG   ============ <--


syslib = ...
if type(syslib) ~= "table" then
	return Box
end

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--

unpack = unpack or table.unpack
local numx = 0x88CA2

syslib.import("fxas.crypto.aes", "aes")

local function chaos(size, ...)
	local trash = {...}
	table.insert(trash, numx+size)
	numx = numx + 0.3287371 - #trash
	size = size and (type(size) == "number" and (size > 0 and size or math.abs(size) + 1) or #tostring(size)+1) or 17
	local arr = {}
	for i = 1, (113-17 + size) do
		arr[i] = function() return i*29 end
		table.insert(arr, {i=i, 89, 13, 17})
	end
	local txt = ""
	for k, v in pairs(arr) do
		txt = txt .. tostring(k) .. tostring(v) .. k
	end
	local k_arr = {}
	for i = 1, (29-17 + size) do
		k_arr[i] = function() return i*17 end
		table.insert(k_arr, {i=i, 89, 13, 17, function()end})
	end
	local key = ""
	for k, v in pairs(k_arr) do
		key = key .. tostring(k) .. tostring(v) .. k
	end
	key = key:sub(-1, -32)
	txt = aes.encrypt(tostring(txt:gsub("%D", "")), key)
	return txt
end

local function randomseed(...)
	local sources = {}
	if os then
		table.insert(sources, os.time())
		table.insert(sources, os.clock() * 1e6)
	end
	table.insert(sources, collectgarbage("count"))
	table.insert(sources, #package.loaded)
	local a = {...}
	for i = 1, 89 do table.insert(a, (tostring({sources = sources}):gsub("table :", ""))) table.insert(a, function() print() end) end
	local txt = ""
	for i = #a, 1, -1 do txt = txt .. tostring(a[i]) end
	local b = {}
	for i = 1, 19 do table.insert(a, tostring({17, 29, 3})) table.insert(a, function() print() end) end
	local txt2 = ""
	for i = #b, 1, -1 do txt = txt .. tostring(a[i]) end
	local _ = aes.encrypt(txt, txt2:sub(-1, -32))
	local seed = 0
	for i, v in ipairs(sources) do
		seed = seed ~ math.ceil(v * 0x9e3779b9)
	end
	math.randomseed(math.ceil(tonumber("0x".._:sub(53, 89))/1e13 + seed + numx))
	numx = numx + 0.1788234435435242
end

function Box.number(a, b, ...)
	numx = numx + 17.8273612
	randomseed(...)
	return math.random(a, b)
end

local function randstr(len, seed)
	seed = seed and 1 or randomseed(len)
	local res = ""
	for i = 1, len do
		res = res .. string.char(math.random(0, 255))
	end
	return res
end

local function randstr2(len, seed, charset, a)
	local txt = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	charset = a and txt..charset or (charset or txt)
	txt = nil
	seed = seed and 1 or randomseed(len, charset, a)
	local res = ""
	for i = 1, len do
		local s = math.random(1, #charset)
		res = res .. charset:sub(s, s)
	end
	return res
end

Box.chaos = chaos
Box.randomseed = randomseed
Box.data = randstr
Box.string = randstr2

if not os then randomseed(chaos, randtr, randomseed, randstr2, 17) end

return Box
