-- Error in library: fxas.crypto.morus >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768657526
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.morus", -- Your package name
	version = 1.0, -- fxas.crypto.morus version
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

local function state_update(s, m0, m1, m2, m3)
	local s00, s01, s02, s03 = s[1],  s[2],  s[3],  s[4]
	local s10, s11, s12, s13 = s[5],  s[6],  s[7],  s[8]
	local s20, s21, s22, s23 = s[9],  s[10], s[11], s[12]
	local s30, s31, s32, s33 = s[13], s[14], s[15], s[16]
	local s40, s41, s42, s43 = s[17], s[18], s[19], s[20]
	local temp
	s00 = s00 ~ s30
	s01 = s01 ~ s31
	s02 = s02 ~ s32
	s03 = s03 ~ s33
	temp = s33
	s33 = s32
	s32 = s31
	s31 = s30
	s30 = temp
	s00 = s00 ~ s10 & s20
	s01 = s01 ~ s11 & s21
	s02 = s02 ~ s12 & s22
	s03 = s03 ~ s13 & s23
	s00 = (s00 << 13) | (s00 >> (64-13))
	s01 = (s01 << 13) | (s01 >> (64-13))
	s02 = (s02 << 13) | (s02 >> (64-13))
	s03 = (s03 << 13) | (s03 >> (64-13))
	s10 = s10 ~ m0
	s11 = s11 ~ m1
	s12 = s12 ~ m2
	s13 = s13 ~ m3
	s10 = s10 ~ s40
	s11 = s11 ~ s41
	s12 = s12 ~ s42
	s13 = s13 ~ s43
	temp = s43
	s43 = s41
	s41 = temp
	temp = s42
	s42 = s40
	s40 = temp
	s10 = s10 ~ (s20 & s30)
	s11 = s11 ~ (s21 & s31)
	s12 = s12 ~ (s22 & s32)
	s13 = s13 ~ (s23 & s33)
	s10 = (s10 << 46) | (s10 >> (64-46))
	s11 = (s11 << 46) | (s11 >> (64-46))
	s12 = (s12 << 46) | (s12 >> (64-46))
	s13 = (s13 << 46) | (s13 >> (64-46))
	s20 = s20 ~ m0
	s21 = s21 ~ m1
	s22 = s22 ~ m2
	s23 = s23 ~ m3
	s20 = s20 ~ s00
	s21 = s21 ~ s01
	s22 = s22 ~ s02
	s23 = s23 ~ s03
	temp = s00
	s00 = s01
	s01 = s02
	s02 = s03
	s03 = temp
	s20 = s20 ~ s30 & s40
	s21 = s21 ~ s31 & s41
	s22 = s22 ~ s32 & s42
	s23 = s23 ~ s33 & s43
	s20 = (s20 << 38) | (s20 >> (64-38))
	s21 = (s21 << 38) | (s21 >> (64-38))
	s22 = (s22 << 38) | (s22 >> (64-38))
	s23 = (s23 << 38) | (s23 >> (64-38))
	s30 = s30 ~ m0
	s31 = s31 ~ m1
	s32 = s32 ~ m2
	s33 = s33 ~ m3
	s30 = s30 ~ s10
	s31 = s31 ~ s11
	s32 = s32 ~ s12
	s33 = s33 ~ s13
	temp = s13
	s13 = s11
	s11 = temp
	temp = s12
	s12 = s10
	s10 = temp
	s30 = s30 ~ s40 & s00
	s31 = s31 ~ s41 & s01
	s32 = s32 ~ s42 & s02
	s33 = s33 ~ s43 & s03
	s30 = (s30 << 7) | (s30 >> (64-7))
	s31 = (s31 << 7) | (s31 >> (64-7))
	s32 = (s32 << 7) | (s32 >> (64-7))
	s33 = (s33 << 7) | (s33 >> (64-7))
	s40 = s40 ~ m0
	s41 = s41 ~ m1
	s42 = s42 ~ m2
	s43 = s43 ~ m3
	s40 = s40 ~ s20
	s41 = s41 ~ s21
	s42 = s42 ~ s22
	s43 = s43 ~ s23
	temp = s23
	s23 = s22
	s22 = s21
	s21 = s20
	s20 = temp
	s40 = s40 ~ s00 & s10
	s41 = s41 ~ s01 & s11
	s42 = s42 ~ s02 & s12
	s43 = s43 ~ s03 & s13
	s40 = (s40 << 4) | (s40 >> (64-4))
	s41 = (s41 << 4) | (s41 >> (64-4))
	s42 = (s42 << 4) | (s42 >> (64-4))
	s43 = (s43 << 4) | (s43 >> (64-4))
	s[1],  s[2],  s[3],  s[4]  = s00, s01, s02, s03
	s[5],  s[6],  s[7],  s[8]  = s10, s11, s12, s13
	s[9],  s[10], s[11], s[12] = s20, s21, s22, s23
	s[13], s[14], s[15], s[16] = s30, s31, s32, s33
	s[17], s[18], s[19], s[20] = s40, s41, s42, s43
end

local function enc_aut_step(s, m0, m1, m2, m3)
	local c0 = m0 ~ s[1] ~ s[6] ~ (s[9]  & s[13])
	local c1 = m1 ~ s[2] ~ s[7] ~ (s[10] & s[14])
	local c2 = m2 ~ s[3] ~ s[8] ~ (s[11] & s[15])
	local c3 = m3 ~ s[4] ~ s[5] ~ (s[12] & s[16])
	state_update(s, m0, m1, m2, m3)
	return c0, c1, c2, c3
end

local function dec_aut_step(s, c0, c1, c2, c3, blen)
	local m0 = c0 ~ s[1] ~ s[6] ~ (s[9]  & s[13])
	local m1 = c1 ~ s[2] ~ s[7] ~ (s[10] & s[14])
	local m2 = c2 ~ s[3] ~ s[8] ~ (s[11] & s[15])
	local m3 = c3 ~ s[4] ~ s[5] ~ (s[12] & s[16])
	if blen then 
		local mblk = spack("<I8I8I8I8", m0, m1, m2, m3):sub(1, blen) 
		local blk = mblk .. string.rep('\0', 32 - blen)
		assert(#blk == 32, #blk)
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", blk)
		state_update(s, m0, m1, m2, m3)
		return mblk
	end
	state_update(s, m0, m1, m2, m3)
	return spack("<I8I8I8I8", m0, m1, m2, m3)
end

local con = {
		0xd08050302010100, 0x6279e99059372215, 
	    0xf12fc26d55183ddb, 0xdd28b57342311120 }
	
local function state_init(key, iv)
	assert((#key == 16) or (#key == 32), "key must be 16 or 32 bytes")
	assert(#iv == 16, "iv must be 16 bytes")
	local ek0, ek1, ek2, ek3 
	if #key == 16 then 
		ek0, ek1 = sunpack("<I8I8", key)
		ek3, ek2 = ek1, ek0
	else
		ek0, ek1, ek2, ek3 = sunpack("<I8I8I8I8", key)
	end
	local iv0, iv1 = sunpack("<I8I8", iv)
	local s = {
		iv0, iv1, 0, 0,
		ek0, ek1, ek2, ek3,
		-1, -1, -1, -1,
		0, 0, 0, 0,
		con[1], con[2], con[3], con[4],
	}
	for i = 1, 16 do state_update(s, 0, 0, 0, 0) end
	s[5] = s[5] ~ ek0
	s[6] = s[6] ~ ek1
	s[7] = s[7] ~ ek2
	s[8] = s[8] ~ ek3
	return s
end

local function tag_compute(s, mlen, adlen)
	local m0, m1, m2, m3 = (adlen << 3), (mlen << 3), 0, 0
	s[17] = s[17] ~ s[1];  s[18] = s[18] ~ s[2]
	s[19] = s[19] ~ s[3];  s[20] = s[20] ~ s[4]
	for i = 1, 10 do state_update(s, m0, m1, m2, m3) end
	s[1] = s[1] ~ s[6] ~ (s[9] & s[13]) -- j=0
	s[2] = s[2] ~ s[7] ~ (s[10] & s[14]) -- j=1
	s[3] = s[3] ~ s[8] ~ (s[11] & s[15]) -- j=2
	s[4] = s[4] ~ s[5] ~ (s[12] & s[16]) -- j=3
	return s[1], s[2] -- tag is state[0][0]..state[0][1]
end

local function encrypt(k, iv, m, ad)
	ad = ad or ""
	local mlen, adlen = #m, #ad
	local m0, m1, m2, m3, c0, c1, c2, c3
	local blk, blen
	local ct = {}
	local s = state_init(k, iv)
	local i = 1
	while i <= adlen - 31 do
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", ad, i)
		i = i + 32
		enc_aut_step(s, m0, m1, m2, m3)
	end
	if i <= adlen then
		blk = ad:sub(i) .. string.rep('\0', 31 + i - adlen)
		assert(#blk == 32, #blk)
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", blk)
		enc_aut_step(s, m0, m1, m2, m3)
	end
	insert(ct, ad)
	i = 1
	while i <= mlen - 31 do
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", m, i)
		i = i + 32
		c0, c1, c2, c3 = enc_aut_step(s, m0, m1, m2, m3)
		insert(ct, spack("<I8I8I8I8", c0, c1, c2, c3))
	end
	if i <= mlen then
		blk = m:sub(i)
		blen = #blk
		blk = blk .. string.rep('\0', 31 + i - mlen)
		assert(#blk == 32, #blk)
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", blk)
		c0, c1, c2, c3 = enc_aut_step(s, m0, m1, m2, m3)
		insert(ct, spack("<I8I8I8I8", c0, c1, c2, c3):sub(1, blen))
	end
	local tag0, tag1 = tag_compute(s, mlen, adlen)
	insert(ct, spack("<I8I8", tag0, tag1))
	return table.concat(ct) 
end

local function decrypt(k, iv, e, adlen)
	adlen = adlen or 0
	local elen = #e - 16
	local mlen = elen - adlen
	local m0, m1, m2, m3, c0, c1, c2, c3
	local blk, blen
	local ct = {}
	local s = state_init(k, iv)
	if adlen > 0 then ad = e:sub(1, adlen) end
	local i = 1
	while i <= adlen - 31 do
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", ad, i)
		i = i + 32
		enc_aut_step(s, m0, m1, m2, m3)
	end
	if i <= adlen then
		blk = ad:sub(i) .. string.rep('\0', 31 + i - adlen)
		assert(#blk == 32, #blk)
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", blk)
		enc_aut_step(s, m0, m1, m2, m3)
	end
	i = adlen + 1
	while i <= elen - 31 do
		c0, c1, c2, c3 = sunpack("<I8I8I8I8", e, i)
		i = i + 32
		blk = dec_aut_step(s, c0, c1, c2, c3)
		insert(ct, blk)
	end
	if i <= elen then
		blk = e:sub(i, elen)
		blen = #blk
		blk = blk .. string.rep('\0', 31 + i - elen)
		assert(#blk == 32, #blk)
		c0, c1, c2, c3 = sunpack("<I8I8I8I8", blk)
		blk = dec_aut_step(s, c0, c1, c2, c3, blen)
		insert(ct, blk)
	end
	local ctag0, ctag1 = tag_compute(s, mlen, adlen)
	local tag0, tag1 = sunpack("<I8I8", e, elen + 1)
	if ((ctag0 ~ tag0) | (ctag1 ~ tag1)) ~= 0 then
		return nil, "decrypt error"
	end
	return table.concat(ct) 
end


local function xof(m, outlen, key)
	outlen = outlen or 32 
	key = key or ""
	key = key .. ('\0'):rep(32 - #key)
	local mlen = #m
	local m0, m1, m2, m3
	local blk, blen
	local iv = spack("<I8I8", outlen, 0)
	local s = state_init(key, iv)
	local i = 1
	while i <= mlen - 31 do --process full blocks
		m0, m1, m2, m3 = sunpack("<I8I8I8I8", m, i)
		i = i + 32
		state_update(s,  m0, m1, m2, m3)
	end
	if mlen - i < 30 then 
		blk = m:sub(i) .. '\x01' .. ('\0'):rep(29 - (mlen - i)) .. '\x80'
		assert(#blk == 32, #blk)
	else
		blk = m:sub(i) .. '\x81'
	end
	m0, m1, m2, m3 = sunpack("<I8I8I8I8", blk)
	state_update(s,  m0, m1, m2, m3)
	for i = 1, 16 do state_update(s, 0, 0, 0, 0) end
	local outt = {}
	local n = 0
	repeat
		blk = spack("<I8I8I8I8", s[1],s[2],s[3],s[4])
		state_update(s, 0, 0, 0, 0)
		n = n + 32
		if n > outlen then
			blk = blk:sub(1, outlen - (n - 32))
			n = outlen
		end
		insert(outt, blk)
	until n >= outlen
	local out = concat(outt)
	assert(#out == outlen)
	return out
end

Box.state_update = state_update
Box.encrypt = encrypt
Box.decrypt = decrypt
Box.key_size = 32
Box.nonce_size = 16
Box.variant = "Morus-1280"
Box.xof = xof -- experimental!! - don't use it for anything!!

return Box
