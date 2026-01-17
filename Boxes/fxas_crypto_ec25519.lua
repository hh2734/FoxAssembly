-- Error in library: fxas.crypto.ec25519 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768657967
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.ec25519", -- Your package name
	version = 1.0, -- fxas.crypto.ec25519 version
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

local function car25519(o)
	local c
	for i = 1, 16 do
		o[i] = o[i] + 65536
		c = o[i] // 65536
		if i < 16 then
			o[i+1] = o[i+1] + (c - 1)
		else
			o[1] = o[1] + 38 * (c - 1)
		end
		o[i] = o[i] - (c << 16)
	end
end

local function sel25519(p, q, b)
	local c = ~(b-1)
	local t
	for i = 1, 16 do
		t = c & (p[i] ~ q[i])
		p[i] = p[i] ~ t
		q[i] = q[i] ~ t
	end
end

local function pack25519(o, n)
	local m, t = {}, {}
	local b
	for i = 1, 16 do t[i] = n[i] end
	car25519(t)
	car25519(t)
	car25519(t)
	for _ = 1, 2 do
		m[1] = t[1] - 0xffed
		for i = 2, 15 do
			m[i] = t[i] - 0xffff - ((m[i-1] >> 16) & 1)
			m[i-1] = m[i-1] & 0xffff
		end
		m[16] = t[16] - 0x7fff - ((m[15] >> 16) & 1)
		b = (m[16] >> 16) & 1
		m[15] = m[15] & 0xffff
		sel25519(t, m, 1-b)
	end
	for i = 1, 16 do
		o[2*i-1] = t[i] & 0xff
		o[2*i] = t[i] >> 8
	end
end

local function unpack25519(o, n)
	for i = 1, 16 do
		o[i] = n[2*i-1] + (n[2*i] << 8)
	end
	o[16] = o[16] & 0x7fff
end

local function A(o, a, b)
	for i = 1, 16 do o[i] = a[i] + b[i] end
end

local function Z(o, a, b)
	for i = 1, 16 do o[i] = a[i] - b[i] end
end

local function M(o, a, b)
	local t = {}
	for i = 1, 32 do t[i] = 0  end
	for i = 1, 16 do
		for j = 1, 16 do
			t[i+j-1] = t[i+j-1] + (a[i] * b[j])
		end
	end
	for i = 1, 15 do t[i] = t[i] + 38 * t[i+16] end
	for i = 1, 16 do o[i] = t[i] end
	car25519(o)
	car25519(o)
end

local function S(o, a)
	M(o, a, a)
end

local function inv25519(o, i)
	local c = {}
	for a = 1, 16 do c[a] = i[a] end
	for a = 253, 0, -1 do
		S(c, c)
		if a ~= 2 and a ~= 4 then M(c, c, i) end
	end
	for a = 1, 16 do o[a] = c[a] end
end

local t_121665 = {0xDB41,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local function crypto_scalarmult(q, n, p)
	local z = {}
	local x = {}
	local a = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local b = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local c = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local d = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local e = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local f = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	for i = 1, 31 do z[i] = n[i] end
	z[32] = (n[32] & 127) | 64
	z[1] = z[1] & 248
	unpack25519(x, p)
	for i = 1, 16 do
		b[i] = x[i]
		a[i] = 0
		c[i] = 0
		d[i] = 0
	end
	a[1] = 1
	d[1] = 1
	for i = 254, 0, -1 do
		local r = (z[(i>>3)+1] >> (i & 7)) & 1
		sel25519(a,b,r)
		sel25519(c,d,r)
		A(e,a,c)
		Z(a,a,c)
		A(c,b,d)
		Z(b,b,d)
		S(d,e)
		S(f,a)
		M(a,c,a)
		M(c,b,e)
		A(e,a,c)
		Z(a,a,c)
		S(b,a)
		Z(c,d,f)
		M(a,c,t_121665)
		A(a,a,d)
		M(c,c,a)
		M(a,d,f)
		M(d,b,x)
		S(b,e)
		sel25519(a,b,r)
		sel25519(c,d,r)
	end
	for i = 1, 16 do
		x[i+16] = a[i]
		x[i+32] = c[i]
		x[i+48] = b[i]
		x[i+64] = d[i]
	end
	local x16, x32 = {}, {}
	for i = 1, #x do
		if i > 16 then x16[i-16] = x[i] end
		if i > 32 then x32[i-32] = x[i] end
	end
	inv25519(x32,x32)
	M(x16,x16,x32)
	pack25519(q,x16)
	return 0
end

local t_9 = {
	9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	}

local function crypto_scalarmult_base(q, n)
	return crypto_scalarmult(q, n, t_9)
end

local function scalarmult(n, p)
	local qt, nt, pt = {}, {}, {} 
	for i = 1, 32 do 
		nt[i] = string.byte(n, i) 
		pt[i] = string.byte(p, i) 
	end
	crypto_scalarmult(qt, nt, pt)
	local q = string.char(table.unpack(qt))
	return q
end
local base = '\9' .. ('\0'):rep(31)

Box.crypto_scalarmult = crypto_scalarmult
Box.crypto_scalarmult_base = crypto_scalarmult_base
Box.scalarmult = scalarmult
Box.base = base

return Box
