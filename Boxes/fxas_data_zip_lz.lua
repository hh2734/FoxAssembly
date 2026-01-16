-- Error in library: fxas.data.zip.lz >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768585105
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.zip.lz", -- Your package name
	version = 1.0, -- fxas.data.zip.lz version
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

local bit32 = {}
local function checkint(name, argidx, x, level)
	local n = tonumber(x)
	if not n then
		error(string.format(
			"bad argument #%d to '%s' (number expected, got %s)",
			argidx, name, type(x)
		), level + 1)
	end
	return math.floor(n)
end
local function checkint32(name, argidx, x, level)
	local n = tonumber(x)
	if not n then
		error(string.format(
			"bad argument #%d to '%s' (number expected, got %s)",
			argidx, name, type(x)
		), level + 1)
	end
	return math.floor(n) & 0xFFFFFFFF
end
function bit32.bnot(x)
	x = checkint32('bnot', 1, x, 2)
	return (~x) & 0xFFFFFFFF
end
function bit32.band(...)
	local args = {...}
	local result = 0xFFFFFFFF
	for i = 1, select('#', ...) do
		local n = checkint32('band', i, args[i], 2)
		result = result & n
	end
	return result & 0xFFFFFFFF
end
function bit32.bor(...)
	local args = {...}
	local result = 0
	for i = 1, select('#', ...) do
		local n = checkint32('bor', i, args[i], 2)
		result = result | n
	end
	return result & 0xFFFFFFFF
end
function bit32.bxor(...)
	local args = {...}
	local result = 0
	for i = 1, select('#', ...) do
		local n = checkint32('bxor', i, args[i], 2)
		result = result ~ n
	end
	return result & 0xFFFFFFFF
end
function bit32.btest(...)
	local args = {...}
	local result = 0xFFFFFFFF
	for i = 1, select('#', ...) do
		local n = checkint32('btest', i, args[i], 2)
		result = result & n
	end
	return result ~= 0
end
function bit32.extract(n, field, width)
	n = checkint32('extract', 1, n, 2)
	field = checkint('extract', 2, field, 2)
	width = checkint('extract', 3, width or 1, 2)
	if field < 0 then
		error("bad argument #2 to 'extract' (field cannot be negative)", 2)
	end
	if width <= 0 then
		error("bad argument #3 to 'extract' (width must be positive)", 2)
	end
	if field + width > 32 then
		error('trying to access non-existent bits', 2)
	end
	return (n >> field) & ((1 << width) - 1)
end
function bit32.replace(n, v, field, width)
	n = checkint32('replace', 1, n, 2)
	v = checkint32('replace', 2, v, 2)
	field = checkint('replace', 3, field, 2)
	width = checkint('replace', 4, width or 1, 2)
	if field < 0 then
		error("bad argument #3 to 'replace' (field cannot be negative)", 2)
	end
	if width <= 0 then
		error("bad argument #4 to 'replace' (width must be positive)", 2)
	end
	if field + width > 32 then
		error('trying to access non-existent bits', 2)
	end
	local mask = ((1 << width) - 1) << field
	return (n & ~mask) | ((v << field) & mask)
end
function bit32.lshift(x, disp)
	x = checkint32('lshift', 1, x, 2)
	disp = checkint('lshift', 2, disp, 2)
	if disp >= 32 then
		return 0
	elseif disp <= -32 then
		return 0
	elseif disp < 0 then
		return (x >> -disp) & 0xFFFFFFFF
	else
		return (x << disp) & 0xFFFFFFFF
	end
end
function bit32.rshift(x, disp)
	x = checkint32('rshift', 1, x, 2)
	disp = checkint('rshift', 2, disp, 2)
	if disp >= 32 then
		return 0
	elseif disp <= -32 then
		return 0
	elseif disp < 0 then
		return (x << -disp) & 0xFFFFFFFF
	else
		return (x >> disp) & 0xFFFFFFFF
	end
end
function bit32.arshift(x, disp)
	x = checkint32('arshift', 1, x, 2)
	disp = checkint('arshift', 2, disp, 2)
	if disp >= 32 then
		return (x & 0x80000000 ~= 0) and 0xFFFFFFFF or 0
	elseif disp <= -32 then
		return 0
	elseif disp < 0 then
		return (x << -disp) & 0xFFFFFFFF
	else
		if x & 0x80000000 == 0 then
			return x >> disp
		else
			local result = x >> disp
			local fill_bits = (disp > 0) and ((-1) << (32 - disp)) or 0
			return result | fill_bits
		end
	end
end
function bit32.lrotate(x, disp)
	x = checkint32('lrotate', 1, x, 2)
	disp = checkint('lrotate', 2, disp, 2) % 32
	if disp == 0 then
		return x
	end
	return ((x << disp) | (x >> (32 - disp))) & 0xFFFFFFFF
end
function bit32.rrotate(x, disp)
	x = checkint32('rrotate', 1, x, 2)
	disp = checkint('rrotate', 2, disp, 2) % 32
	if disp == 0 then
		return x
	end
	return ((x >> disp) | (x << (32 - disp))) & 0xFFFFFFFF
end

-- https://github.com/RiskoZoSlovenska/llz4
local band, lshift, rshift do
	local ok, customBit = pcall(require, "bit")
	local bit = bit or (ok and customBit or nil)

	local ok, customBit32 = pcall(require, "bit32")
	local bit32 = bit32 or (ok and customBit32 or nil)

	if bit then
		band, lshift, rshift = bit.band, bit.lshift, bit.rshift
	elseif bit32 then
		band, lshift, rshift = bit32.band, bit32.lshift, bit32.rshift
	else
		band   = assert(load("return function(x, n) return x &  n end"))()
		lshift = assert(load("return function(x, n) return x << n end"))()
		rshift = assert(load("return function(x, n) return x >> n end"))()
	end
end

local string_byte = string.byte

local MIN_MATCH = 4
local MIN_LENGTH = 13
local MIN_TRAILING_LITERALS = 5
local MISS_COUNTER_BITS = 6
local HASH_SHIFT = 32 - 16
local MAX_DISTANCE = 0xFFFF

local LIT_COUNT_BITS = 4
local LIT_COUNT_MASK = lshift(1, LIT_COUNT_BITS) - 1
local MATCH_LEN_BITS = 4
local MATCH_LEN_MASK = lshift(1, MATCH_LEN_BITS) - 1

local CHAR_MAP = {}
for i = 0, 255 do
	CHAR_MAP[i] = string.char(i)
end
local CHAR_0xFF = string.char(0xFF)


local function readU32LE(str, index)
	local a, b, c, d = string_byte(str, index, index + 3)
	return a + lshift(b, 8) + lshift(c, 16) + lshift(d, 24)
end

function Box.compress(data, acceleration)
	assert(type(data) == "string", "bad argument #1 to 'compress' (string expected, got " .. type(data) .. ")")
	acceleration = acceleration or 1
	assert(type(acceleration) == "number", "bad argument #2 to 'compress' (number expected, got " .. type(acceleration) .. ")")
	assert(acceleration >= 1 and acceleration % 1 == 0, "acceleration must be an integer >= 1")

	local hashTable = {}
	local out, outNext = {}, 1

	local pos, dataLen = 1, #data
	local nextUnencodedPos = pos

	if dataLen >= MIN_LENGTH then
		local stepAndMissCounterInit = lshift(acceleration, MISS_COUNTER_BITS)
		local stepAndMissCounter = stepAndMissCounterInit

		while pos + MIN_MATCH <= dataLen - MIN_TRAILING_LITERALS do
			local sequence = readU32LE(data, pos)
			local hash = rshift(sequence * 2654435761, HASH_SHIFT)

			local matchPos = hashTable[hash]
			hashTable[hash] = pos

			if not matchPos or pos - matchPos > MAX_DISTANCE or readU32LE(data, matchPos) ~= sequence then
				pos = pos + rshift(stepAndMissCounter, MISS_COUNTER_BITS)
				stepAndMissCounter = stepAndMissCounter + 1
				goto continue
			end

			stepAndMissCounter = stepAndMissCounterInit

			local literalCount = pos - nextUnencodedPos
			local matchOffset = pos - matchPos

			while literalCount > 0 and matchPos > 0 and string_byte(data, pos - 1) == string_byte(data, matchPos - 1) do
				literalCount = literalCount - 1
				pos = pos - 1
				matchPos = matchPos - 1
			end

			pos = pos + MIN_MATCH
			matchPos = matchPos + MIN_MATCH

			local matchLength = pos
			while pos <= dataLen - MIN_TRAILING_LITERALS and string_byte(data, pos) == string_byte(data, matchPos) do
				pos = pos + 1
				matchPos = matchPos + 1
			end
			matchLength = pos - matchLength

			local literalCountHalf = (literalCount < LIT_COUNT_MASK) and literalCount or LIT_COUNT_MASK
			local matchLenHalf = (matchLength < MATCH_LEN_MASK) and matchLength or MATCH_LEN_MASK
			local token = lshift(literalCountHalf, MATCH_LEN_BITS) + matchLenHalf
			out[outNext] = CHAR_MAP[token]
			outNext = outNext + 1

			local remaining = literalCount - LIT_COUNT_MASK
			while remaining >= 0xFF do
				out[outNext] = CHAR_0xFF
				outNext = outNext + 1
				remaining = remaining - 0xFF
			end
			if remaining >= 0 then
				out[outNext] = CHAR_MAP[remaining]
				outNext = outNext + 1
			end

			for i = 0, literalCount - 1 do
				out[outNext + i] = CHAR_MAP[string_byte(data, nextUnencodedPos + i)]
			end
			outNext = outNext + literalCount

			out[outNext	] = CHAR_MAP[band(matchOffset, 0xFF)]
			out[outNext + 1] = CHAR_MAP[rshift(matchOffset, 8)]
			outNext = outNext + 2

			remaining = matchLength - MATCH_LEN_MASK
			while remaining >= 0xFF do
				out[outNext] = CHAR_0xFF
				outNext = outNext + 1
				remaining = remaining - 0xFF
			end
			if remaining >= 0 then
				out[outNext] = CHAR_MAP[remaining]
				outNext = outNext + 1
			end

			nextUnencodedPos = pos

			::continue::
		end
	end

	local literalCount = dataLen - nextUnencodedPos + 1
	local token = lshift((literalCount < LIT_COUNT_MASK) and literalCount or LIT_COUNT_MASK, MATCH_LEN_BITS)
	out[outNext] = CHAR_MAP[token]
	outNext = outNext + 1

	local remaining = literalCount - LIT_COUNT_MASK
	while remaining >= 0xFF do
		out[outNext] = CHAR_0xFF
		outNext = outNext + 1
		remaining = remaining - 0xFF
	end
	if remaining >= 0 then
		out[outNext] = CHAR_MAP[remaining]
		outNext = outNext + 1
	end

	out[outNext] = string.sub(data, nextUnencodedPos)

	return table.concat(out)
end

function Box.decompress(data)
	assert(type(data) == "string", "bad argument #1 to 'decompress' (string expected, got " .. type(data) .. ")")

	local out, outNext = {}, 1

	local dataLen = #data
	local pos = 1
	while pos <= dataLen do
		local token = string_byte(data, pos)
		pos = pos + 1

		local literalCount = rshift(token, MATCH_LEN_BITS)

		if literalCount == LIT_COUNT_MASK then
			repeat
				local lenPart = string_byte(data, pos)
				pos = pos + 1
				literalCount = literalCount + lenPart
			until lenPart < 0xFF
		end

		for i = 0, literalCount - 1 do
			out[outNext + i] = CHAR_MAP[string_byte(data, pos + i)]
		end
		outNext = outNext + literalCount
		pos = pos + literalCount

		if pos > dataLen then
			break
		end

		local matchLength = band(token, MATCH_LEN_MASK)

		local offsetA, offsetB = string_byte(data, pos, pos + 1)
		local matchOffset = offsetA + lshift(offsetB, 8)
		pos = pos + 2

		if matchLength == MATCH_LEN_MASK then
			repeat
				local lenPart = string_byte(data, pos)
				pos = pos + 1
				matchLength = matchLength + lenPart
			until lenPart < 0xFF
		end

		matchLength = matchLength + MIN_MATCH

		for i = 0, matchLength - 1 do
			out[outNext + i] = out[outNext - matchOffset + i]
		end
		outNext = outNext + matchLength
	end

	return table.concat(out)
end

return Box
