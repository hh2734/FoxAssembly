-- Error in library: fxas.data.crc32 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768654721
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.crc32", -- Your package name
	version = 1.0, -- fxas.data.crc32 version
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

local type = type
local require = require
local setmetatable = setmetatable

local bit32 = {}

local function checkint( name, argidx, x, level )
	local n = tonumber( x )
	if not n then
		error( string.format(
			"bad argument #%d to '%s' (number expected, got %s)",
			argidx, name, type( x )
		), level + 1 )
	end
	return math.floor( n )
end

local function checkint32( name, argidx, x, level )
	local n = tonumber( x )
	if not n then
		error( string.format(
			"bad argument #%d to '%s' (number expected, got %s)",
			argidx, name, type( x )
		), level + 1 )
	end
	return math.floor( n ) % 0x100000000
end

function bit32.bnot( x )
	x = checkint32( 'bnot', 1, x, 2 )
	return ( -x - 1 ) % 0x100000000
end
local logic_and = {
	[0] = { [0] = 0, 0, 0, 0},
	[1] = { [0] = 0, 1, 0, 1},
	[2] = { [0] = 0, 0, 2, 2},
	[3] = { [0] = 0, 1, 2, 3},
}
local logic_or = {
	[0] = { [0] = 0, 1, 2, 3},
	[1] = { [0] = 1, 1, 3, 3},
	[2] = { [0] = 2, 3, 2, 3},
	[3] = { [0] = 3, 3, 3, 3},
}
local logic_xor = {
	[0] = { [0] = 0, 1, 2, 3},
	[1] = { [0] = 1, 0, 3, 2},
	[2] = { [0] = 2, 3, 0, 1},
	[3] = { [0] = 3, 2, 1, 0},
}

local function comb( name, args, nargs, s, t )
	for i = 1, nargs do
		args[i] = checkint32( name, i, args[i], 3 )
	end

	local pow = 1
	local ret = 0
	for b = 0, 31, 2 do
		local c = s
		for i = 1, nargs do
			c = t[c][args[i] % 4]
			args[i] = math.floor( args[i] / 4 )
		end
		ret = ret + c * pow
		pow = pow * 4
	end
	return ret
end

function bit32.band( ... )
	return comb( 'band', { ... }, select( '#', ... ), 3, logic_and )
end

function bit32.bor( ... )
	return comb( 'bor', { ... }, select( '#', ... ), 0, logic_or )
end

function bit32.bxor( ... )
	return comb( 'bxor', { ... }, select( '#', ... ), 0, logic_xor )
end

function bit32.btest( ... )
	return comb( 'btest', { ... }, select( '#', ... ), 3, logic_and ) ~= 0
end

function bit32.extract( n, field, width )
	n = checkint32( 'extract', 1, n, 2 )
	field = checkint( 'extract', 2, field, 2 )
	width = checkint( 'extract', 3, width or 1, 2 )
	if field < 0 then
		error( "bad argument #2 to 'extract' (field cannot be negative)", 2 )
	end
	if width <= 0 then
		error( "bad argument #3 to 'extract' (width must be positive)", 2 )
	end
	if field + width > 32 then
		error( 'trying to access non-existent bits', 2 )
	end

	return math.floor( n / 2^field ) % 2^width
end

function bit32.replace( n, v, field, width )
	n = checkint32( 'replace', 1, n, 2 )
	v = checkint32( 'replace', 2, v, 2 )
	field = checkint( 'replace', 3, field, 2 )
	width = checkint( 'replace', 4, width or 1, 2 )
	if field < 0 then
		error( "bad argument #3 to 'replace' (field cannot be negative)", 2 )
	end
	if width <= 0 then
		error( "bad argument #4 to 'replace' (width must be positive)", 2 )
	end
	if field + width > 32 then
		error( 'trying to access non-existent bits', 2 )
	end

	local f = 2^field
	local w = 2^width
	local fw = f * w
	return ( n % f ) + ( v % w ) * f + math.floor( n / fw ) * fw
end

local function checkdisp( name, x )
	x = checkint( name, 2, x, 3 )
	return math.min( math.max( -32, x ), 32 )
end

function bit32.lshift( x, disp )
	x = checkint32( 'lshift', 1, x, 2 )
	disp = checkdisp( 'lshift', disp )
	return math.floor( x * 2^disp ) % 0x100000000
end

function bit32.rshift( x, disp )
	x = checkint32( 'rshift', 1, x, 2 )
	disp = checkdisp( 'rshift', disp )
	return math.floor( x / 2^disp ) % 0x100000000
end

function bit32.arshift( x, disp )
	x = checkint32( 'arshift', 1, x, 2 )
	disp = checkdisp( 'arshift', disp )
	if disp <= 0 then
		return ( x * 2^-disp ) % 0x100000000
	elseif x < 0x80000000 then
		return math.floor( x / 2^disp )
	elseif disp > 31 then
		return 0xffffffff
	else
		return math.floor( x / 2^disp ) + ( 0x100000000 - 2 ^ ( 32 - disp ) )
	end
end

function bit32.lrotate( x, disp )
	x = checkint32( 'lrotate', 1, x, 2 )
	disp = checkint( 'lrotate', 2, disp, 2 ) % 32
	local x = x * 2^disp
	return ( x % 0x100000000 ) + math.floor( x / 0x100000000 )
end

function bit32.rrotate( x, disp )
	x = checkint32( 'rrotate', 1, x, 2 )
	disp = -checkint( 'rrotate', 2, disp, 2 ) % 32
	local x = x * 2^disp
	return ( x % 0x100000000 ) + math.floor( x / 0x100000000 )
end

local bit = bit32
local bxor = bit.bxor
local bnot = bit.bnot
local band = bit.band
local rshift = bit.rshift

local POLY = 0xEDB88320

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k); t[k] = v
		return v
	end
	return t
end

local crc_table = memoize(function(i)
	local crc = i
	for _=1,8 do
		local b = band(crc, 1)
		crc = rshift(crc, 1)
		if b == 1 then crc = bxor(crc, POLY) end
	end
	return crc
end)

function Box.crc32_byte(byte, crc)
	crc = bnot(crc or 0)
	local v1 = rshift(crc, 8)
	local v2 = crc_table[bxor(crc % 256, byte)]
	return bnot(bxor(v1, v2))
end
local M_crc32_byte = Box.crc32_byte

function Box.crc32_string(s, crc)
	crc = crc or 0
	for i=1,#s do
		crc = M_crc32_byte(s:byte(i), crc)
	end
	return crc
end
local M_crc32_string = Box.crc32_string

function Box.crc32(s, crc)
	if type(s) == 'string' then
		return M_crc32_string(s, crc)
	else
		return M_crc32_byte(s, crc)
	end
end

Box.bit = bit32

return Box
