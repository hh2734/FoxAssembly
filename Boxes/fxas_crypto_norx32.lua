-- Error in library: fxas.crypto.norx32 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768656809
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.norx32", -- Your package name
	version = 1.0, -- fxas.crypto.norx32 version
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
local insert, concat = table.insert, table.concat
local HEADER_TAG  = 0x01
local PAYLOAD_TAG = 0x02
local TRAILER_TAG = 0x04
local FINAL_TAG   = 0x08

local function G(s, a, b, c, d)
	local A, B, C, D = s[a], s[b], s[c], s[d]
	A = (A ~ B) ~ ((A & B) << 1) & 0xffffffff
	D = D ~ A; D = ((D >> 8) | (D << 24)) & 0xffffffff
	C = (C ~ D) ~ ((C & D) << 1) & 0xffffffff
	B = B ~ C; B = ((B >> 11) | (B << 21)) & 0xffffffff
	A = (A ~ B) ~ ((A & B) << 1) & 0xffffffff
	D = D ~ A; D = ((D >> 16) | (D << 16)) & 0xffffffff
	C = (C ~ D) ~ ((C & D) << 1) & 0xffffffff
	B = B ~ C; B = ((B >> 31) | (B << 1)) & 0xffffffff
	s[a], s[b], s[c], s[d] = A, B, C, D
end

local function F(s)
	G(s,  1,  5,  9, 13);
    G(s,  2,  6, 10, 14);
    G(s,  3,  7, 11, 15);
    G(s,  4,  8, 12, 16);
    G(s,  1,  6, 11, 16);
    G(s,  2,  7, 12, 13);
    G(s,  3,  8,  9, 14);
    G(s,  4,  5, 10, 15);
end

local function permute(s)
	for _ = 1, 4 do F(s) end
end

local function pad(ins)
	local out
	local inslen = #ins
	if inslen == 47 then return ins .. '\x81' end
	out = ins .. '\x01' .. string.rep('\0', 46-inslen) .. '\x80'
	assert(#out == 48)
	return out
end

local function absorb_block(s, ins, ini, tag)
	s[16] = s[16] ~ tag
	permute(s)
	for i = 1, 12 do
		s[i] = s[i] ~ sunpack("<I4", ins, ini + (i-1)*4)
	end
end

local function absorb_lastblock(s, last, tag)
	absorb_block(s, pad(last), 1, tag)
end

local function encrypt_block(s, out_table, ins, ini)
	s[16] = s[16] ~ PAYLOAD_TAG
	permute(s)
	for i = 1, 12 do
		s[i] = s[i] ~ sunpack("<I4", ins, ini + (i-1)*4)
		insert(out_table, spack("<I4", s[i]))
	end
end

local function encrypt_lastblock(s, out_table, last)
	local t = {}
	local lastlen = #last
	last = pad(last)
	encrypt_block(s, t, last, 1)
	last = concat(t)
	last = last:sub(1, lastlen)
	insert(out_table, last)
end

local function decrypt_block(s, out_table, ins, ini)
	s[16] = s[16] ~ PAYLOAD_TAG
	permute(s)
	for i = 1, 12 do
		local c = sunpack("<I4", ins, ini + (i-1)*4)
		insert(out_table, spack("<I4", s[i] ~ c))
		s[i] = c
	end
end

local function decrypt_lastblock(s, out_table, last)
	local lastlen = #last
	s[16] = s[16] ~ PAYLOAD_TAG
	permute(s)
	local byte, char = string.byte, string.char
	local lastblock_s4_table = {}
	for i = 1, 12 do
		local s4 = spack("<I4", s[i])
		insert(lastblock_s4_table, s4)
	end
	local lastblock = concat(lastblock_s4_table)
	local lastblock_byte_table = {}
	for i = 1, 48 do
		lastblock_byte_table[i] = byte(lastblock, i)
	end
	for i = 1, lastlen do
		lastblock_byte_table[i] = byte(last, i)
	end
	lastblock_byte_table[lastlen+1] = lastblock_byte_table[lastlen+1] ~ 0x01
	lastblock_byte_table[48] = lastblock_byte_table[48] ~ 0x80
	local lastblock_char_table = {}
	for i = 1, 48 do
		lastblock_char_table[i] = char(lastblock_byte_table[i])
	end
	lastblock = concat(lastblock_char_table)
	local t = {}
	for i = 1, 12 do
		local c = sunpack("<I4", lastblock, 1 + (i-1)*4)
		local x = spack("<I4", s[i] ~ c)
		insert(t, x)
		s[i] = c
	end
	last = concat(t)
	last = last:sub(1, lastlen)
	insert(out_table, last)
end

local function init(k, n)
	local s = {}
	for i = 1, 16 do s[i] = i-1 end
	F(s)
	F(s)
	s[1], s[2], s[3], s[4] = sunpack("<I4I4I4I4", n)
	local k1, k2, k3, k4 = sunpack("<I4I4I4I4", k)
	s[5], s[6], s[7], s[8] =  k1, k2, k3, k4
	s[13] = s[13] ~ 32
	s[14] = s[14] ~ 4
	s[15] = s[15] ~ 1
	s[16] = s[16] ~ 128
	permute(s)
	s[13] = s[13] ~ k1
	s[14] = s[14] ~ k2
	s[15] = s[15] ~ k3
	s[16] = s[16] ~ k4
	return s
end

local function absorb_data(s, ins, tag)
	local inlen = #ins
	local i = 1
	if inlen > 0 then
		while inlen >= 48 do
			absorb_block(s, ins, i, tag)
			inlen = inlen - 48
			i = i + 48
		end
		absorb_lastblock(s, ins:sub(i), tag)
	end
end

local function encrypt_data(s, out_table, ins)
	local inlen = #ins
	local i = 1
	if inlen > 0 then
		while inlen >= 48 do
			encrypt_block(s, out_table, ins, i)
			inlen = inlen - 48
			i = i + 48
		end
		encrypt_lastblock(s, out_table, ins:sub(i))
	end
end

local function decrypt_data(s, out_table, ins)
	local inlen = #ins
	local i = 1
	if inlen > 0 then
		while inlen >= 48 do
			decrypt_block(s, out_table, ins, i)
			inlen = inlen - 48
			i = i + 48
		end
		decrypt_lastblock(s, out_table, ins:sub(i))
	end
end

local function finalize(s, k)
	s[16] = s[16] ~ FINAL_TAG
	permute(s)
	local k1, k2, k3, k4 = sunpack("<I4I4I4I4", k)
	s[13] = s[13] ~ k1
	s[14] = s[14] ~ k2
	s[15] = s[15] ~ k3
	s[16] = s[16] ~ k4
	permute(s)
	s[13] = s[13] ~ k1
	s[14] = s[14] ~ k2
	s[15] = s[15] ~ k3
	s[16] = s[16] ~ k4
	local authtag = spack("<I4I4I4I4", s[13], s[14], s[15], s[16])
	return authtag
end

local function verify_tag(tag1, tag2)
	return tag1 == tag2
end

local function aead_encrypt(key, nonce, plain, header, trailer)
	header = header or ""
	trailer = trailer or ""
	local out_table = {}
	assert(#key == 16, "key must be 16-byte long")
	assert(#nonce == 16, "nonce must be 16-byte long")
	local state = init(key, nonce)
	absorb_data(state, header, HEADER_TAG)
	encrypt_data(state, out_table, plain)
	absorb_data(state, trailer, TRAILER_TAG)
	local tag = finalize(state, key)
	insert(out_table, tag)
	local crypted = concat(out_table)
	assert(#crypted == #plain + 16)
	return crypted
end

local function aead_decrypt(key, nonce, crypted, header, trailer)
	header = header or ""
	trailer = trailer or ""
	assert(#key == 16, "key must be 16-byte long")
	assert(#nonce == 16, "nonce must be 16-byte long")
	assert(#crypted >= 16)
	local out_table = {}
	local state = init(key, nonce)
	absorb_data(state, header, HEADER_TAG)
	local ctag = crypted:sub(#crypted - 16 + 1)
	local c = crypted:sub(1, #crypted - 16)
	decrypt_data(state, out_table, c)
	absorb_data(state, trailer, TRAILER_TAG)
	local tag = finalize(state, key)
	if not verify_tag(tag, ctag) then return nil, "auth failure" end
	local plain = concat(out_table)
	return plain
end

Box.aead_encrypt = aead_encrypt
Box.aead_decrypt = aead_decrypt
Box.key_size = 16
Box.nonce_size = 16
Box.variant = "NORX 32-4-1"

return Box
