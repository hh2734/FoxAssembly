-- Error in library: fxas.util.bin >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768652647
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.util.bin", -- Your package name
	version = 1.0, -- fxas.util.bin version
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

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

local function hex(s, ln, sep)
	if #s == 0 then return "" end
	if not ln then
		return (s:gsub('.',
			function(c) return strf('%02x', byte(c)) end
			))
	end
	sep = sep or ""
	local t = {}
	for i = 1, #s - 1 do
		t[#t + 1] = strf("%02x%s", s:byte(i),
				(i % ln == 0) and '\n' or sep)
	end
	t[#t + 1] = strf("%02x", s:byte(#s))
	return concat(t)
end

local function dehex(hs, unsafe)
	local tonumber = tonumber
	if not unsafe then
		hs = string.gsub(hs, "%s+", "")
		if string.find(hs, '[^0-9A-Za-z]') or #hs % 2 ~= 0 then
			error("invalid hex string")
		end
	end
	return hs:gsub(	'(%x%x)',
		function(c) return char(tonumber(c, 16)) end
		)
end

local function rotr32(i, n)
	return ((i >> n) | (i << (32 - n))) & 0xffffffff
end

local function rotl32(i, n)
	return ((i << n) | (i >> (32 - n))) & 0xffffffff
end

local function xor1(key, plain)
	local ot = {}
	local ki, kln = 1, #key
	for i = 1, #plain do
		ot[#ot + 1] = char(byte(plain, i) ~ byte(key, ki))
		ki = ki + 1
		if ki > kln then ki = 1 end
	end
	return concat(ot)
end

local function xor8(key, plain)
	assert(#key % 8 == 0, 'key not a multiple of 8 bytes')
	local ka = {}
	for i = 1, #key, 8 do
		app(ka, (sunpack("<I8", key, i)))
	end
	local kaln = #ka
	local rbn = #plain
	local kai = 1
	local ot = {}
	local ibu
	local ob
	for i = 1, #plain, 8 do
		if rbn < 8 then
			local buffer = string.sub(plain, i) .. string.rep('\0', 8 - rbn)
			ibu = sunpack("<I8", buffer)
			ob = string.sub(spack("<I8", ibu ~ ka[kai]), 1, rbn)
		else
			ibu = sunpack("<I8", plain, i)
			ob = spack("<I8", ibu ~ ka[kai])
			rbn = rbn - 8
			kai = (kai < kaln) and (kai + 1) or 1
		end
		app(ot, ob)
	end
	return concat(ot)
end

Box.hex = hex
Box.dehex = dehex
Box.rotr32 = rotr32
Box.rotl32 = rotl32
Box.xor1 = xor1
Box.xor8 = xor8

return Box
