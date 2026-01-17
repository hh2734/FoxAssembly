-- Error in library: fxas.data.blake2b >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768655061
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.blake2b", -- Your package name
	version = 1.0, -- fxas.data.blake2b version
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

local sunpack = string.unpack
local concat = table.concat

local function ROTR64(x, n)
	return (x >> n) | (x << (64-n))
end

local function G(v, a, b, c, d, x, y)
	v[a] = v[a] + v[b] + x
	v[d] = ROTR64(v[d] ~ v[a], 32)
	v[c] = v[c] + v[d]
	v[b] = ROTR64(v[b] ~ v[c], 24)
	v[a] = v[a] + v[b] + y
	v[d] = ROTR64(v[d] ~ v[a], 16)
	v[c] = v[c] + v[d]
	v[b] = ROTR64(v[b] ~ v[c], 63)
end

local iv = {
	0x6a09e667f3bcc908, 0xbb67ae8584caa73b,
	0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
	0x510e527fade682d1, 0x9b05688c2b3e6c1f,
	0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
}

local sigma = {
	{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 },
	{ 15, 11, 5, 9, 10, 16, 14, 7, 2, 13, 1, 3, 12, 8, 6, 4 },
	{ 12, 9, 13, 1, 6, 3, 16, 14, 11, 15, 4, 7, 8, 2, 10, 5 },
	{ 8, 10, 4, 2, 14, 13, 12, 15, 3, 7, 6, 11, 5, 1, 16, 9 },
	{ 10, 1, 6, 8, 3, 5, 11, 16, 15, 2, 12, 13, 7, 9, 4, 14 },
	{ 3, 13, 7, 11, 1, 12, 9, 4, 5, 14, 8, 6, 16, 15, 2, 10 },
	{ 13, 6, 2, 16, 15, 14, 5, 11, 1, 8, 7, 4, 10, 3, 9, 12 },
	{ 14, 12, 8, 15, 13, 2, 4, 10, 6, 1, 16, 5, 9, 7, 3, 11 },
	{ 7, 16, 15, 10, 12, 4, 1, 9, 13, 3, 14, 8, 2, 5, 11, 6 },
	{ 11, 3, 9, 5, 8, 7, 2, 6, 16, 12, 10, 15, 4, 13, 14, 1 },
	{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 },
	{ 15, 11, 5, 9, 10, 16, 14, 7, 2, 13, 1, 3, 12, 8, 6, 4 }
}

local function compress(ctx, last)
	local v, m = {}, {}
	for i = 1, 8 do
		v[i] = ctx.h[i]
		v[i+8] = iv[i]
	end
	v[13] = v[13] ~ ctx.t[1]
	v[14] = v[14] ~ ctx.t[2]
	if last then v[15] = ~v[15] end
	for i = 0, 15 do
		m[i+1] = sunpack("<I8", ctx.b, i*8+1)
	end

	for i = 1, 12 do
		G(v, 1, 5, 9, 13, m[sigma[i][ 1]], m[sigma[i][ 2]])
		G(v, 2, 6,10, 14, m[sigma[i][ 3]], m[sigma[i][ 4]])
		G(v, 3, 7,11, 15, m[sigma[i][ 5]], m[sigma[i][ 6]])
		G(v, 4, 8,12, 16, m[sigma[i][ 7]], m[sigma[i][ 8]])
		G(v, 1, 6,11, 16, m[sigma[i][ 9]], m[sigma[i][10]])
		G(v, 2, 7,12, 13, m[sigma[i][11]], m[sigma[i][12]])
		G(v, 3, 8, 9, 14, m[sigma[i][13]], m[sigma[i][14]])
		G(v, 4, 5,10, 15, m[sigma[i][15]], m[sigma[i][16]])

	end

	for i = 1, 8 do
		ctx.h[i] = ctx.h[i] ~ v[i] ~ v[i + 8]
	end
end

local update

local function init(outlen, key)
	outlen = outlen or 64
	key = key or ""
	local keylen = #key
	if outlen < 1 or outlen > 64 or (key and #key > 64) then
		return nil, "illegal parameters"
	end
	local ctx = {h={}, t={}, c=1, outlen=outlen}
	for i = 1, 8 do ctx.h[i] = iv[i] end
	ctx.h[1] = ctx.h[1] ~ 0x01010000 ~ (keylen << 8) ~ outlen
	ctx.t[1] = 0
	ctx.t[2] = 0
	ctx.b = ""
	if keylen > 0 then
		update(ctx, key)
		ctx.b = ctx.b .. string.rep('\0', 128 - #ctx.b)
		assert(#ctx.b == 128)
	end
	return ctx
end

update = function(ctx, data)
	local bln, rln, iln
	local i = 1
	while true do
		bln = #ctx.b
		assert(bln <= 128)
		if bln == 128 then
			ctx.t[1] = ctx.t[1] + 128
			compress(ctx, false)
			ctx.b = ""
		else
			rln =  128 - bln
			iln = #data - i + 1
			if iln < rln then
				ctx.b = ctx.b .. data:sub(i, i + iln -1)
				break
			else
				ctx.b = ctx.b .. data:sub(i, i + rln -1)
				i = i + rln
			end
		end
	end
end

local function final(ctx)
	local bln = #ctx.b
	ctx.t[1] = ctx.t[1] + bln
	local rln =  128 - bln
	ctx.b = ctx.b .. string.rep('\0', rln)
	compress(ctx, true)
	local outtbl = {}
	for i = 0, ctx.outlen - 1 do
		outtbl[i+1] = string.char(
			(ctx.h[(i >> 3) + 1] >> (8 * (i & 7))) & 0xff)
	end
	local dig = concat(outtbl)
	return dig
end

local function hash(data, outlen, key)
	local ctx, msg = init(outlen, key)
	if not ctx then return ctx, msg end
	update(ctx, data)
	return final(ctx)
end

Box.init = init
Box.update = update
Box.final = final
Box.hash = hash

return Box
