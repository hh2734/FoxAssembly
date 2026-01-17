-- Error in library: fxas.crypto.rabbit >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768656585
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.rabbit", -- Your package name
	version = 1.0, -- fxas.crypto.rabbit version
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
local app, concat = table.insert, table.concat

local function rotl32(i, n)
	return ((i << n) | (i >> (32 - n))) & 0xffffffff
end

local function gfunc(x)
	local h = x * x
	local l = h & 0xffffffff
	h = h >> 32
	return h ~ l
end

local function newstate()
	return {
		x = {0,0,0,0,0,0,0,0},  -- 8 * u32
		c = {0,0,0,0,0,0,0,0},  -- 8 * u32
		co = {0,0,0,0,0,0,0,0},  -- 8 * u32
		g = {0,0,0,0,0,0,0,0},  -- 8 * u32
		carry = 0  -- u32
	}
end

local function clonestate(st)
	local nst = newstate()
	for i = 1, 8 do
		nst.x[i] = st.x[i]
		nst.c[i] = st.c[i]
	end
	nst.carry = st.carry
	return nst
end

local function nextstate(st)
	local x, c, co, g = st.x, st.c, st.co, st.g
	local rl = rotl32
	for i = 1, 8 do  co[i] = c[i]  end
	c[1] = (c[1] + 0x4D34D34D + st.carry) & 0xffffffff
	c[2] = (c[2] + 0xD34D34D3 + (c[1] < co[1] and 1 or 0)) & 0xffffffff
	c[3] = (c[3] + 0x34D34D34 + (c[2] < co[2] and 1 or 0)) & 0xffffffff
	c[4] = (c[4] + 0x4D34D34D + (c[3] < co[3] and 1 or 0)) & 0xffffffff
	c[5] = (c[5] + 0xD34D34D3 + (c[4] < co[4] and 1 or 0)) & 0xffffffff
	c[6] = (c[6] + 0x34D34D34 + (c[5] < co[5] and 1 or 0)) & 0xffffffff
	c[7] = (c[7] + 0x4D34D34D + (c[6] < co[6] and 1 or 0)) & 0xffffffff
	c[8] = (c[8] + 0xD34D34D3 + (c[7] < co[7] and 1 or 0)) & 0xffffffff
	st.carry = c[8] < co[8] and 1 or 0
	for i = 1, 8 do g[i] = gfunc((x[i] + c[i]) & 0xffffffff) end
	x[1] = (g[1] + rl(g[8],16) + rl(g[7],16)) & 0xffffffff
	x[2] = (g[2] + rl(g[1],8) + g[8]) & 0xffffffff
	x[3] = (g[3] + rl(g[2],16) + rl(g[1],16)) & 0xffffffff
	x[4] = (g[4] + rl(g[3],8) + g[2]) & 0xffffffff
	x[5] = (g[5] + rl(g[4],16) + rl(g[3],16)) & 0xffffffff
	x[6] = (g[6] + rl(g[5],8) + g[4]) & 0xffffffff
	x[7] = (g[7] + rl(g[6],16) + rl(g[5],16)) & 0xffffffff
	x[8] = (g[8] + rl(g[7],8) + g[6]) & 0xffffffff
end

local function keysetup(st, key)
	assert(#key == 16)
	local k1, k2, k3, k4 = sunpack("<I4I4I4I4", key)
	local x, c = st.x, st.c
	x[1] = k1
	x[3] = k2
	x[5] = k3
	x[7] = k4
	x[2] = ((k4<<16) & 0xffffffff | (k3>>16))
	x[4] = ((k1<<16) & 0xffffffff | (k4>>16))
	x[6] = ((k2<<16) & 0xffffffff | (k1>>16))
	x[8] = ((k3<<16) & 0xffffffff | (k2>>16))
	c[1] = rotl32(k3, 16)
	c[3] = rotl32(k4, 16)
	c[5] = rotl32(k1, 16)
	c[7] = rotl32(k2, 16)
	c[2] = (k1 & 0xffff0000) | (k2 & 0xffff)
	c[4] = (k2 & 0xffff0000) | (k3 & 0xffff)
	c[6] = (k3 & 0xffff0000) | (k4 & 0xffff)
	c[8] = (k4 & 0xffff0000) | (k1 & 0xffff)
	st.carry = 0
	for _ = 1, 4 do
		nextstate(st)
	end
	for i = 1, 4 do c[i] = c[i] ~ x[i+4] end
	for i = 5, 8 do c[i] = c[i] ~ x[i-4] end
end

local function ivsetup(st, iv)
	assert(#iv == 8)
	local i1, i2, i3, i4
	i1, i3 = sunpack("<I4I4", iv)
	i2 = (i1 >> 16) | (i3 & 0xffff0000)
	i4 = (i3 << 16) & 0xffffffff | (i1 & 0x0000ffff)
	local c = st.c
	c[1] = c[1] ~ i1
	c[2] = c[2] ~ i2
	c[3] = c[3] ~ i3
	c[4] = c[4] ~ i4
	c[5] = c[5] ~ i1
	c[6] = c[6] ~ i2
	c[7] = c[7] ~ i3
	c[8] = c[8] ~ i4
	for _ = 1, 4 do  nextstate(st)  end
end

local function processblock(st, itxt, idx)
	local i1, i2, i3, i4
	local o1, o2, o3, o4
	local bn = #itxt - idx + 1
	local last = bn <= 16
	local short = bn < 16
	local fmt = "<I4I4I4I4"
	if short then
		local buffer = string.sub(itxt, idx) .. string.rep('\0', 16 - bn)
		itxt = buffer
		idx = 1
	end
	i1, i2, i3, i4 = sunpack(fmt, itxt, idx)
	nextstate(st)
	local x = st.x
	o1 = i1 ~ x[1] ~ (x[6] >> 16) ~ ((x[4] << 16) & 0xffffffff)
	o2 = i2 ~ x[3] ~ (x[8] >> 16) ~ ((x[6] << 16) & 0xffffffff)
	o3 = i3 ~ x[5] ~ (x[2] >> 16) ~ ((x[8] << 16) & 0xffffffff)
	o4 = i4 ~ x[7] ~ (x[4] >> 16) ~ ((x[2] << 16) & 0xffffffff)
	local outstr = spack(fmt, o1, o2, o3, o4)
	if short then
		outstr = string.sub(outstr, 1, bn)
	end
	return outstr, last
end

local function crypt(key, iv, text)
	local st = newstate()
	keysetup(st, key)
	ivsetup(st, iv)
	if #text == 0 then return "" end
	local ot = {}
	local ob, last
	local idx = 1
	repeat
		ob, last = processblock(st, text, idx)
		idx = idx + 16
		app(ot, ob)
	until last
	return concat(ot)
end

Box.encrypt = crypt
Box.decrypt = crypt
Box.key_size = 16
Box.iv_size = 8
Box.newstate = newstate
Box.clonestate = clonestate
Box.keysetup = keysetup
Box.ivsetup = ivsetup
Box.processblock = processblock

return Box
