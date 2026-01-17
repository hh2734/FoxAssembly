-- Error in library: fxas.data.base85 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768655674
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.base85", -- Your package name
	version = 1.0, -- fxas.data.base85 version
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

local spack, sunpack = string.pack, string.unpack
local byte, char = string.byte, string.char
local insert, concat = table.insert, table.concat

local chars =  
	"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	.. ".-:+=^!/*?&<>()[]{}@%$#"

local inv = {}
for i = 1, #chars do inv[byte(chars, i)] = i - 1 end

local function encode(s)
	local n, r1, r2, r3, r4, r5
	assert(#s % 4 == 0, "string length must be multiple of 4 bytes")
	local et = {}
	for i = 1, #s, 4 do
		n = sunpack(">I4", s, i)
		r5 = n % 85 ; n = n // 85
		r4 = n % 85 ; n = n // 85
		r3 = n % 85 ; n = n // 85
		r2 = n % 85 ; n = n // 85
		r1 = n % 85 ; n = n // 85
		local eb = char(
			chars:byte(r1 + 1),
			chars:byte(r2 + 1),
			chars:byte(r3 + 1),
			chars:byte(r4 + 1),
			chars:byte(r5 + 1))
		insert(et, eb)
	end
	return table.concat(et)
end

local function decode(e)
	local st = {}
	local n, r1, r2, r3, r4, r5
	if #e % 5 ~= 0 then
		return nil, "invalid length" 
	end
	for i = 1, #e, 5 do
		n = 0
		for j = 0, 4 do
			r = inv[e:byte(i+j)]
			if not r then 
				return nil, "invalid char"
			end
			n = n * 85 + r
		end
		local sb = spack(">I4", n)
		insert(st, sb)
	end
	return table.concat(st)
end

Box.encode = encode
Box.decode = decode

return Box
