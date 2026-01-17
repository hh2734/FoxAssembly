-- Error in library: fxas.crypto.chacha20 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768658591
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.chacha20", -- Your package name
	version = 1.0, -- fxas.crypto.chacha20 version
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
	a = (a + b) & 0xffffffff
	t = d ~ a ; d = ((t << 16) | (t >> (16))) & 0xffffffff
	c = (c + d) & 0xffffffff
	t = b ~ c ; b = ((t << 12) | (t >> (20))) & 0xffffffff
	a = (a + b) & 0xffffffff
	t = d ~ a ; d = ((t << 8) | (t >> (24))) & 0xffffffff
	c = (c + d) & 0xffffffff
	t = b ~ c ; b = ((t << 7) | (t >> (25))) & 0xffffffff
	st[x], st[y], st[z], st[w] = a, b, c, d
	return st
end

local chacha20_state = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local chacha20_working_state = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local chacha20_block = function(key, counter, nonce)
	local st = chacha20_state
	local wst = chacha20_working_state
	st[1], st[2], st[3], st[4] =
		0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	for i = 1, 8 do st[i+4] = key[i] end
	st[13] = counter
	for i = 1, 3 do st[i+13] = nonce[i] end
	for i = 1, 16 do wst[i] = st[i] end
	for _ = 1, 10 do
		qround(wst, 1,5,9,13)
		qround(wst, 2,6,10,14)
		qround(wst, 3,7,11,15)
		qround(wst, 4,8,12,16)
		qround(wst, 1,6,11,16)
		qround(wst, 2,7,12,13)
		qround(wst, 3,8,9,14)
		qround(wst, 4,5,10,15)
	end
	for i = 1, 16 do st[i] = (st[i] + wst[i]) & 0xffffffff end
	return st
end

local pat16 = "<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4"

local function chacha20_encrypt_block(key, counter, nonce, pt, ptidx)
	local rbn = #pt - ptidx + 1
	if rbn < 64 then
		local tmp = string.sub(pt, ptidx)
		pt = tmp .. string.rep('\0', 64 - rbn)
		ptidx = 1
	end
	assert(#pt >= 64)
	local ba = table.pack(string.unpack(pat16, pt, ptidx))
	local keystream = chacha20_block(key, counter, nonce)
	for i = 1, 16 do
		ba[i] = ba[i] ~ keystream[i]
	end
	local es = string.pack(pat16, table.unpack(ba))
	if rbn < 64 then
		es = string.sub(es, 1, rbn)
	end
	return es
end

local chacha20_encrypt = function(key, counter, nonce, pt)
	assert((counter + #pt // 64 + 1) < 0xffffffff, "block counter must fit an uint32")
	assert(#key == 32, "#key must be 32")
	assert(#nonce == 12, "#nonce must be 12")
	local keya = table.pack(string.unpack("<I4I4I4I4I4I4I4I4", key))
	local noncea = table.pack(string.unpack("<I4I4I4", nonce))
	local t = {}
	local ptidx = 1
	while ptidx <= #pt do
		app(t, chacha20_encrypt_block(keya, counter, noncea, pt, ptidx))
		ptidx = ptidx + 64
		counter = counter + 1
	end
	local et = concat(t)
	return et
end

local function hchacha20(key, nonce16)
	local keya = table.pack(string.unpack("<I4I4I4I4I4I4I4I4", key))
	local noncea = table.pack(string.unpack("<I4I4I4I4", nonce16))
	local st = {}
	st[1], st[2], st[3], st[4] =
		0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	for i = 1, 8 do st[i+4] = keya[i] end
	for i = 1, 4 do st[i+12] = noncea[i] end
	for _ = 1, 10 do
		qround(st, 1,5,9,13)
		qround(st, 2,6,10,14)
		qround(st, 3,7,11,15)
		qround(st, 4,8,12,16)
		qround(st, 1,6,11,16)
		qround(st, 2,7,12,13)
		qround(st, 3,8,9,14)
		qround(st, 4,5,10,15)
	end	
	local subkey = string.pack("<I4I4I4I4I4I4I4I4", 
		st[1], st[2], st[3], st[4],
		st[13], st[14], st[15], st[16] )
	return subkey
end

local function xchacha20_encrypt(key, counter, nonce, pt)
	assert(#key == 32, "#key must be 32")
	assert(#nonce == 24, "#nonce must be 24")
	local subkey = hchacha20(key, nonce:sub(1, 16))
	local nonce12 = '\0\0\0\0'..nonce:sub(17)
	return chacha20_encrypt(subkey, counter, nonce12, pt)
end

Box.chacha20_encrypt = chacha20_encrypt
Box.chacha20_decrypt = chacha20_encrypt
Box.encrypt = chacha20_encrypt
Box.decrypt = chacha20_encrypt
Box.hchacha20 = hchacha20
Box.xchacha20_encrypt = xchacha20_encrypt
Box.xchacha20_decrypt = xchacha20_encrypt
Box.key_size = 32
Box.nonce_size = 12
Box.xnonce_size = 24

return Box
