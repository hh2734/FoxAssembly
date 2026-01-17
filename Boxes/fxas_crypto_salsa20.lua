-- Error in library: fxas.crypto.salsa20 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768656183
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.salsa20", -- Your package name
	version = 1.0, -- fxas.crypto.salsa20 version
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

local app, concat = table.insert, table.concat

local function qround(st,x,y,z,w)
	local a, b, c, d = st[x], st[y], st[z], st[w]
	local t
	t = (a + d) & 0xffffffff
	b = b ~ ((t << 7) | (t >> 25)) & 0xffffffff
	t = (b + a) & 0xffffffff
	c = c ~ ((t << 9) | (t >> 23)) & 0xffffffff
	t = (c + b) & 0xffffffff
	d = d ~ ((t << 13) | (t >> 19)) & 0xffffffff
	t = (d + c) & 0xffffffff
	a = a ~ ((t << 18) | (t >> 14)) & 0xffffffff
	st[x], st[y], st[z], st[w] = a, b, c, d
	return st
end

local salsa20_state = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local salsa20_working_state = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local salsa20_block = function(key, counter, nonce)
	local st = salsa20_state
	local wst = salsa20_working_state
	st[1], st[6], st[11], st[16] =
		0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	for i = 1, 4 do
		st[i+1] = key[i]
		st[i+11] = key[i+4]
	end
	st[7], st[8], st[9], st[10] = nonce[1], nonce[2], counter[1], counter[2]
	for i = 1, 16 do wst[i] = st[i] end
	for _ = 1, 10 do
		qround(wst, 1,5,9,13)
		qround(wst, 6,10,14,2)
		qround(wst, 11,15,3,7)
		qround(wst, 16,4,8,12)
		qround(wst, 1,2,3,4)
		qround(wst, 6,7,8,5)
		qround(wst, 11,12,9,10)
		qround(wst, 16,13,14,15)
	end
	for i = 1, 16 do st[i] = (st[i] + wst[i]) & 0xffffffff end
	return st
end

local function hsalsa20_block(key, counter, nonce)
	local st = salsa20_block(key, counter, nonce)
	return {
		(st[1] - 0x61707865) & 0xffffffff,
		(st[6] - 0x3320646e) & 0xffffffff,
		(st[11] - 0x79622d32) & 0xffffffff,
		(st[16] - 0x6b206574) & 0xffffffff,
		(st[7] - nonce[1]) & 0xffffffff,
		(st[8] - nonce[2]) & 0xffffffff,
		(st[9] - counter[1]) & 0xffffffff,
		(st[10] - counter[2]) & 0xffffffff,
	}
end

local pat16 = "<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4"

local pat8 = "<I4I4I4I4I4I4I4I4"

local function salsa20_encrypt_block(key, counter, nonce, pt, ptidx)
	local rbn = #pt - ptidx + 1
	if rbn < 64 then
		local tmp = string.sub(pt, ptidx)
		pt = tmp .. string.rep('\0', 64 - rbn) --pad last block
		ptidx = 1
	end
	assert(#pt >= 64)
	local ba = table.pack(string.unpack(pat16, pt, ptidx))
	local keystream = salsa20_block(key, counter, nonce)
	for i = 1, 16 do
		ba[i] = ba[i] ~ keystream[i]
	end
	local es = string.pack(pat16, table.unpack(ba))
	if rbn < 64 then
		es = string.sub(es, 1, rbn)
	end
	return es
end

local salsa20_encrypt = function(key, counter, nonce, pt)
	assert(#key == 32, "#key must be 32")
	assert(#nonce == 8, "#nonce must be 8")
	local keya = table.pack(string.unpack("<I4I4I4I4I4I4I4I4", key))
	local noncea = table.pack(string.unpack("<I4I4", nonce))
	local countera = {counter & 0xffffffff, counter >> 32}
	local t = {}
	local ptidx = 1
	while ptidx <= #pt do
		app(t, salsa20_encrypt_block(keya, countera, noncea, pt, ptidx))
		ptidx = ptidx + 64
		countera[1] = countera[1] + 1
		if countera[1] > 0xffffffff then
			countera[1] = 0
			countera[2] = countera[2] + 1
		end
	end
	return (concat(t))
end

local function salsa20_stream(key, counter, nonce, length)
	assert(#key == 32, "#key must be 32")
	assert(#nonce == 8, "#nonce must be 8")
	local keya = table.pack(string.unpack("<I4I4I4I4I4I4I4I4", key))
	local noncea = table.pack(string.unpack("<I4I4", nonce))
	local countera = {counter & 0xffffffff, counter >> 32}
	local t = {}
	while length > 0 do
		local keystream = salsa20_block(keya, countera, noncea)
		local block = string.pack(pat16, table.unpack(keystream))
		if length <= 64 then block = block:sub(1, length) end
		app(t, block)
		length = length - 64
		countera[1] = countera[1] + 1
		if countera[1] > 0xffffffff then
			countera[1] = 0
			countera[2] = countera[2] + 1
		end
	end
	return (concat(t))
end

local hsalsa20 = function(key, counter, nonce)
	assert(#key == 32, "#key must be 32")
	assert(#nonce == 8, "#nonce must be 8")
	local keya = table.pack(string.unpack("<I4I4I4I4I4I4I4I4", key))
	local noncea = table.pack(string.unpack("<I4I4", nonce))
	local countera = {counter & 0xffffffff, counter >> 32}
	local stream = hsalsa20_block(keya, countera, noncea)
	return string.pack(pat8, table.unpack(stream))
end

Box.encrypt = salsa20_encrypt
Box.decrypt = salsa20_encrypt
Box.stream = salsa20_stream
Box.hsalsa20 = hsalsa20
Box.key_size = 32
Box.nonce_size = 8

return Box
