-- Error in library: fxas.data.sha3 >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768653947
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.sha3", -- Your package name
	version = 1.0, -- fxas.data.sha3 version
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

local char = string.char
local concat = table.concat
local spack, sunpack = string.pack, string.unpack

local ROUNDS = 24

local roundConstants = {
0x0000000000000001,
0x0000000000008082,
0x800000000000808A,
0x8000000080008000,
0x000000000000808B,
0x0000000080000001,
0x8000000080008081,
0x8000000000008009,
0x000000000000008A,
0x0000000000000088,
0x0000000080008009,
0x000000008000000A,
0x000000008000808B,
0x800000000000008B,
0x8000000000008089,
0x8000000000008003,
0x8000000000008002,
0x8000000000000080,
0x000000000000800A,
0x800000008000000A,
0x8000000080008081,
0x8000000000008080,
0x0000000080000001,
0x8000000080008008
}

local rotationOffsets = {
{0, 36, 3, 41, 18},
{1, 44, 10, 45, 2},
{62, 6, 43, 15, 61},
{28, 55, 25, 21, 56},
{27, 20, 39, 8, 14}
}

local function keccakF(st)
	local permuted = st.permuted
	local parities = st.parities
	for round = 1, ROUNDS do
		for x = 1,5 do
			parities[x] = 0
			local sx = st[x]
			for y = 1,5 do parities[x] = parities[x] ~ sx[y] end
		end
		local p5, flip, s
		p5 = parities[2]
		flip = parities[5] ~ (p5 << 1 | p5 >> 63)
		s = st[1]
		for y = 1,5 do s[y] = s[y] ~ flip end
		p5 = parities[3]
		flip = parities[1] ~ (p5 << 1 | p5 >> 63)
		s = st[2]
		for y = 1,5 do s[y] = s[y] ~ flip end
		p5 = parities[4]
		flip = parities[2] ~ (p5 << 1 | p5 >> 63)
		s = st[3]
		for y = 1,5 do s[y] = s[y] ~ flip end
		p5 = parities[5]
		flip = parities[3] ~ (p5 << 1 | p5 >> 63)
		s = st[4]
		for y = 1,5 do s[y] = s[y] ~ flip end
		p5 = parities[1]
		flip = parities[4] ~ (p5 << 1 | p5 >> 63)
		s = st[5]
		for y = 1,5 do s[y] = s[y] ~ flip end
		for y = 1,5 do
			local py = permuted[y]
			local r
			for x = 1,5 do
				s, r = st[x][y], rotationOffsets[x][y]
				py[(2*x + 3*y)%5 + 1] = (s << r | s >> (64-r))
			end
		end
		local p, p1, p2
		s, p, p1, p2 = st[1], permuted[1], permuted[2], permuted[3]
		for y = 1,5 do s[y] = p[y] ~ (~ p1[y]) & p2[y] end
		s, p, p1, p2 = st[2], permuted[2], permuted[3], permuted[4]
		for y = 1,5 do s[y] = p[y] ~ (~ p1[y]) & p2[y] end
		s, p, p1, p2 = st[3], permuted[3], permuted[4], permuted[5]
		for y = 1,5 do s[y] = p[y] ~ (~ p1[y]) & p2[y] end
		s, p, p1, p2 = st[4], permuted[4], permuted[5], permuted[1]
		for y = 1,5 do s[y] = p[y] ~ (~ p1[y]) & p2[y] end
		s, p, p1, p2 = st[5], permuted[5], permuted[1], permuted[2]
		for y = 1,5 do s[y] = p[y] ~ (~ p1[y]) & p2[y] end
		st[1][1] = st[1][1] ~ roundConstants[round]
	end
end


local function absorb(st, buffer)

	local blockBytes = st.rate / 8
	local blockWords = blockBytes / 8

	local totalBytes = #buffer + 1

	buffer = buffer .. ( '\x06' .. char(0):rep(blockBytes - (totalBytes % blockBytes)))
	totalBytes = #buffer
	local words = {}
	for i = 1, totalBytes - (totalBytes % 8), 8 do
		words[#words + 1] = sunpack('<I8', buffer, i)
	end

	local totalWords = #words
	words[totalWords] = words[totalWords] | 0x8000000000000000
	for startBlock = 1, totalWords, blockWords do
		local offset = 0
		for y = 1, 5 do
			for x = 1, 5 do
				if offset < blockWords then
					local index = startBlock+offset
					st[x][y] = st[x][y] ~ words[index]
					offset = offset + 1
				end
			end
		end
		keccakF(st)
	end
end

local function squeeze(st)
	local blockBytes = st.rate / 8
	local blockWords = blockBytes / 4
	local hasht = {}
	local offset = 1
	for y = 1, 5 do
		for x = 1, 5 do
			if offset < blockWords then
				hasht[offset] = spack("<I8", st[x][y])
				offset = offset + 1
			end
		end
	end
	return concat(hasht)
end

local function keccakHash(rate, length, data)
	local state = {	{0,0,0,0,0},
					{0,0,0,0,0},
					{0,0,0,0,0},
					{0,0,0,0,0},
					{0,0,0,0,0},
	}
	state.rate = rate
	state.permuted = { {}, {}, {}, {}, {}, }
	state.parities = {0,0,0,0,0}
	absorb(state, data)
	return squeeze(state):sub(1,length/8)
end

local function keccak256Bin(data) return keccakHash(1088, 256, data) end
local function keccak512Bin(data) return keccakHash(576, 512, data) end

Box.sha256 = keccak256Bin
Box.sha512 = keccak512Bin

return Box
