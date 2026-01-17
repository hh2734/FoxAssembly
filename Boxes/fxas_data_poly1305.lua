-- Error in library: fxas.data.poly1305 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768654211
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.poly1305", -- Your package name
	version = 1.0, -- fxas.data.poly1305 version
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

local sunp = string.unpack

local function poly_init(k)
	local st = {
		r = {
			(sunp('<I4', k,  1)     ) & 0x3ffffff,  --r0
			(sunp('<I4', k,  4) >> 2) & 0x3ffff03,  --r1
			(sunp('<I4', k,  7) >> 4) & 0x3ffc0ff,  --r2
			(sunp('<I4', k, 10) >> 6) & 0x3f03fff,  --r3
			(sunp('<I4', k, 13) >> 8) & 0x00fffff,  --r4
		},
		h = { 0,0,0,0,0 },
		pad = {	sunp('<I4', k, 17),  -- 's' in rfc
			sunp('<I4', k, 21),
			sunp('<I4', k, 25),
			sunp('<I4', k, 29),
		},
		buffer = "", --
		leftover = 0,
		final = false,
	}
	return st
end

local function poly_blocks(st, m)
	local bytes = #m
	local midx = 1
	local hibit = st.final and 0 or 0x01000000 -- 1 << 24
	local r0 = st.r[1]
	local r1 = st.r[2]
	local r2 = st.r[3]
	local r3 = st.r[4]
	local r4 = st.r[5]
	local s1 = r1 * 5
	local s2 = r2 * 5
	local s3 = r3 * 5
	local s4 = r4 * 5
	local h0 = st.h[1]
	local h1 = st.h[2]
	local h2 = st.h[3]
	local h3 = st.h[4]
	local h4 = st.h[5]
	local d0, d1, d2, d3, d4, c
	while bytes >= 16 do
		h0 = h0 + ((sunp('<I4', m, midx     )     ) & 0x3ffffff)
		h1 = h1 + ((sunp('<I4', m, midx +  3) >> 2) & 0x3ffffff)
		h2 = h2 + ((sunp('<I4', m, midx +  6) >> 4) & 0x3ffffff)
		h3 = h3 + ((sunp('<I4', m, midx +  9) >> 6) & 0x3ffffff)
		h4 = h4 + ((sunp('<I4', m, midx + 12) >> 8) | hibit)
		d0 = h0*r0 + h1*s4 + h2*s3 + h3*s2 + h4*s1
		d1 = h0*r1 + h1*r0 + h2*s4 + h3*s3 + h4*s2
		d2 = h0*r2 + h1*r1 + h2*r0 + h3*s4 + h4*s3
		d3 = h0*r3 + h1*r2 + h2*r1 + h3*r0 + h4*s4
		d4 = h0*r4 + h1*r3 + h2*r2 + h3*r1 + h4*r0
		--
		              c = (d0>>26) & 0xffffffff ; h0 = d0 & 0x3ffffff
		d1 = d1 + c ; c = (d1>>26) & 0xffffffff ; h1 = d1 & 0x3ffffff
		d2 = d2 + c ; c = (d2>>26) & 0xffffffff ; h2 = d2 & 0x3ffffff
		d3 = d3 + c ; c = (d3>>26) & 0xffffffff ; h3 = d3 & 0x3ffffff
		d4 = d4 + c ; c = (d4>>26) & 0xffffffff ; h4 = d4 & 0x3ffffff
		h0 = h0 + (c*5) ; c = h0>>26 ; h0 = h0 & 0x3ffffff
		h1 = h1 + c
		bytes = bytes - 16
	end
	st.h[1] = h0
	st.h[2] = h1
	st.h[3] = h2
	st.h[4] = h3
	st.h[5] = h4
	st.bytes = bytes
	st.midx = midx
	return st
end

local function poly_update(st, m)
	st.bytes, st.midx = #m, 1
	if st.bytes >= 16 then
		poly_blocks(st, m)
	end
	if st.bytes == 0 then
	else
		local buffer = 	string.sub(m, st.midx)
			.. '\x01' .. string.rep('\0', 16 - st.bytes -1)
		assert(#buffer == 16)
		st.final = true
--~ 		p16(buffer)
		poly_blocks(st, buffer)
	end
	return st
end

local function poly_finish(st)
	local c, mask
	local f
	local h0 = st.h[1]
	local h1 = st.h[2]
	local h2 = st.h[3]
	local h3 = st.h[4]
	local h4 = st.h[5]
	c = h1 >> 26; h1 = h1 & 0x3ffffff
	h2 = h2 +     c; c = h2 >> 26; h2 = h2 & 0x3ffffff
	h3 = h3 +     c; c = h3 >> 26; h3 = h3 & 0x3ffffff
	h4 = h4 +     c; c = h4 >> 26; h4 = h4 & 0x3ffffff
	h0 = h0 + (c*5); c = h0 >> 26; h0 = h0 & 0x3ffffff
	h1 = h1 + c
	local g0 = (h0 + 5) ; c = g0 >> 26; g0 = g0 & 0x3ffffff
	local g1 = (h1 + c) ; c = g1 >> 26; g1 = g1 & 0x3ffffff
	local g2 = (h2 + c) ; c = g2 >> 26; g2 = g2 & 0x3ffffff
	local g3 = (h3 + c) ; c = g3 >> 26; g3 = g3 & 0x3ffffff
	local g4 = (h4 + c - 0x4000000) &0xffffffff
	mask = ((g4 >> 31) -1) & 0xffffffff
	g0 = g0 & mask
	g1 = g1 & mask
	g2 = g2 & mask
	g3 = g3 & mask
	g4 = g4 & mask
	mask = (~mask)  & 0xffffffff
	h0 = (h0 & mask) | g0
	h1 = (h1 & mask) | g1
	h2 = (h2 & mask) | g2
	h3 = (h3 & mask) | g3
	h4 = (h4 & mask) | g4
	h0 = ((h0      ) | (h1 << 26)) & 0xffffffff
	h1 = ((h1 >>  6) | (h2 << 20)) & 0xffffffff
	h2 = ((h2 >> 12) | (h3 << 14)) & 0xffffffff
	h3 = ((h3 >> 18) | (h4 <<  8)) & 0xffffffff
	f = h0 + st.pad[1]             ; h0 = f & 0xffffffff
	f = h1 + st.pad[2] + (f >> 32) ; h1 = f & 0xffffffff
	f = h2 + st.pad[3] + (f >> 32) ; h2 = f & 0xffffffff
	f = h3 + st.pad[4] + (f >> 32) ; h3 = f & 0xffffffff
	local mac = string.pack('<I4I4I4I4', h0, h1, h2, h3)
	return mac
end

local function poly_auth(m, k)
	assert(#k == 32)
	local st = poly_init(k)
	poly_update(st, m)
	local mac = poly_finish(st)
	return mac
end

local function poly_verify(m, k, mac)
	local macm = poly_auth(m, k)
	return macm == mac
end

Box.init = poly_init
Box.update = poly_update
Box.finish = poly_finish
Box.auth = poly_auth
Box.verify = poly_verify

return Box
