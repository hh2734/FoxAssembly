-- Error in library: fxas.data.base58 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768655671
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.base58", -- Your package name
	version = 1.0, -- fxas.data.base58 version
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

local byte, char, concat = string.byte, string.char, table.concat

local b58chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

local function encode(s)
	local q, b
	local et = {}
	local zn = 0
	local nt = {}
	local dt = {}
	local more = true
	for i = 1, #s do
		b = byte(s, i)
		if more and b == 0 then
			zn = zn + 1
		else
			more = false
		end
		nt[i] = b
	end
	if #s == zn then
		return string.rep('1', zn)
	end
	more = true
	while more do
		local r = 0
		more = false
		for i = 1, #nt do
			b = nt[i] + (256 * r)
			q = b // 58
			more = more or q > 0
			r = b % 58
			dt[i] = q
		end
		table.insert(et, 1, char(byte(b58chars, r+1)))
		nt = {}
		for i = 1, #dt do nt[i] = dt[i] end
		dt = {}
	end
	return string.rep('1', zn) .. concat(et)
end

local b58charmap = {};
for i = 1, 58 do b58charmap[byte(b58chars, i)] = i - 1  end

local function decode(s)
	if string.find(s, "[^"..b58chars.."]") then
		return nil, "invalid char"
	end
	local zn
	zn = #(string.match(s, "^(1+)") or "")
	s = string.gsub(s, "^(1+)", "")
	if s == "" then
		return string.rep('\x00', zn)
	end
	local dn
	local d
	local b
	local m
	local carry
	dn = { b58charmap[byte(s, 1)] }
	for i = 2, #s do
		d = b58charmap[byte(s, i)]
		carry = 0
		for j = 1, #dn do
			b = dn[j]
			m = b * 58 + carry
			b = m & 0xff
			carry = m >> 8
			dn[j] = b
		end
		if carry > 0 then dn[#dn + 1] = carry end
		carry = d
		for j = 1, #dn do
			b = dn[j] + carry
			carry = b >> 8
			dn[j] = b & 0xff
		end
		if carry > 0 then dn[#dn + 1] = carry end
	end
	local ben = {}
	local ln = #dn
	for i = 1, ln do
		ben[i] = char(dn[ln-i+1])
	end
	return string.rep('\x00', zn) .. concat(ben)
end

Box.encode = encode
Box.decode = decode

return Box
