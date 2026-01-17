-- Error in library: fxas.lib.checksum >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768653797
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.lib.checksum", -- Your package name
	version = 1.0, -- fxas.lib.checksum version
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

local byte = string.byte

local function adler32(s)
	local prime = 65521
	local s1, s2 = 1, 0
	if #s > (1 << 40) then error("adler32: string too large") end
	for i = 1,#s do
		local b = byte(s, i)
		s1 = s1 + b
		s2 = s2 + s1
	end
	s1 = s1 % prime
	s2 = s2 % prime
	return (s2 << 16) + s1
end

local function crc32_nt(s)
	local b, crc, mask
	crc = 0xffffffff
	for i = 1, #s do
		b = byte(s, i)
		crc = crc ~ b
		for _ = 1, 8 do
			mask = -(crc & 1)
			crc = (crc >> 1) ~ (0xedb88320 & mask)
		end
	end
	return (~crc) & 0xffffffff
end

local function crc32(s, lt)
	lt = lt or {}
	local b, crc, mask
	if not lt[1] then
		for i = 1, 256 do
			crc = i - 1
			for _ = 1, 8 do
				mask = -(crc & 1)
				crc = (crc >> 1) ~ (0xedb88320 & mask)
			end
			lt[i] = crc
		end
	end
	crc = 0xffffffff
	for i = 1, #s do
		b = byte(s, i)
		crc = (crc >> 8) ~ lt[((crc ~ b) & 0xFF) + 1]
	end
	return (~crc) & 0xffffffff
end

Box.adler32 = adler32
Box.decode_crc32 = crc32_nt
Box.crc32 = crc32

return Box
