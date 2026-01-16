-- Error in library: fxas.data.zip.deflate >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768585227
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.zip.deflate", -- Your package name
	version = 1.0, -- fxas.data.zip.deflate version
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

--https://gist.githubusercontent.com/MCJack123/6c64c9c129c639b5ecf0028924cec69a/raw/a816ed6979591e602116423cd27275e0dea0c903/deflate-ans.lua

local bit32_band, bit32_rshift, bit32_lshift, bit32_bor, math_frexp, math_max, math_min, math_floor, table_sort, table_concat, string_char = bit32.band, bit32.rshift, bit32.lshift, bit32.bor, math.frexp, math.max, math.min, math.floor, table.sort, table.concat, string.char
local function log2(n) local _, r = math_frexp(n) return r-1 end
local function code(n) return n == 0 and 0 or 2^(n-1) end
local function print(...) end local function write(...) end

local staticLs, staticDistLs, clOrd = {R = 9}, {R = 5}, {16, 17, 18}
for i = 0, 143 do staticLs[i+1] = {i, 2} end
for i = 144, 255 do staticLs[i+1] = {i, 1} end
for i = 256, 279 do staticLs[i+1] = {i, 4} end
for i = 280, 287 do staticLs[i+1] = {i, 2} end
for i = 0, 31 do staticDistLs[i+1] = {i, 1} end
for i = 0, 7 do clOrd[#clOrd+1], clOrd[#clOrd+2] = (8 - i) % 8, 8 + i end

local function makeReader(str)
	local partial, bits, pos = 0, 0, 1
	local function readbits(n)
		if not n then n = bits % 8 end
		if n <= 0 then return 0 end
		while bits < n do assert(pos <= #str) pos, bits, partial = pos + 1, bits + 8, bit32_lshift(partial, 8) + str:byte(pos) end
		local retval = bit32_band(bit32_rshift(partial, bits-n), 2^n-1)
		bits = bits - n
		return retval
	end
	return readbits
end

local function generateDecodeTable(Ls)
	local R, L = Ls.R, 2^Ls.R
	local X, step, decodingTable, next, symbol = 0, L < 16 and 3 or 0.625 * L + 3, {R = R}, {}, {}
	if R < 0 then return decodingTable end
	for i = 1, #Ls do
		local p = Ls[i]
		next[p[1]] = p[2]
		for _ = 1, p[2] do while symbol[X] do X = (X + 1) % L end X, symbol[X] = (X + step) % L, p[1] end
	end
	for X = 0, L - 1 do
		local s = symbol[X]
		local t = {s = s, n = R - log2(next[s])}
		t.X, decodingTable[X], next[s] = bit32_lshift(next[s], t.n) - L, t, 1 + next[s]
	end
	return decodingTable
end

local function ansdecode(readbits, nsym, decodingTable, distDecodingTable)
	local X, XL, i, retval = readbits(decodingTable.R), distDecodingTable and readbits(distDecodingTable.R), 1, {}
	while i <= nsym do
		local t = decodingTable[X]
		local s = t.s
		if s == 256 then return retval
		elseif s > 256 then
			local lencode = s - 257
			local ebits = math_max(math_floor(lencode / 4) - 1, 0)
			if ebits > 0 then lencode = 2 + bit32_bor(readbits(ebits), bit32_lshift(bit32_band(lencode, 3) + 4, ebits))
			else lencode = lencode + 2 end
			local tL = distDecodingTable[XL]
			local distcode = tL.s
			ebits = math_max(math_floor(distcode / 2) - 1, 0)
			if ebits > 0 then distcode = 1 + bit32_bor(readbits(ebits), bit32_lshift(bit32_band(distcode, 1) + 2, ebits))
			else distcode = distcode + 1 end
			for j = 0, lencode do retval[i+j] = retval[i+j-distcode] end
			i, XL = i + lencode + 1, tL.X + readbits(tL.n)
		elseif not distDecodingTable and s > 15 then
			local len
			if s == 16 then s, len = retval[i-1], 3 + readbits(2)
			elseif s == 17 then s, len = 0, 3 + readbits(3)
			else s, len = 0, 11 + readbits(7) end
			for j = 0, len-1 do retval[i+j] = s end
			i = i + len
		else
			retval[i], i = s, i + 1
		end
		X = t.X + readbits(t.n)
	end
	return retval
end

local function inflate(data)
	local reader, retval = makeReader(data), ""
	repeat
		local final, typ = reader(1) == 1, reader(2)
		if typ == 0 then
			reader()
			local size = reader(16)
			assert(bit32.bxor(reader(16), size) == 0xFFFF, "invalid chunk")
			for _ = 1, size do retval = retval .. string_char(reader(8)) end
		elseif typ == 1 or typ == 2 then
			local Ls, distLs
			if typ == 1 then
				Ls, distLs = staticLs, staticDistLs
			else
				local hLit, hDist, hcLen, clLs = reader(5) + 257, reader(5) + 1, reader(4) + 4, {R = 0}
				for i = 1, hcLen do
					local c = code(reader(3))
					clLs.R, clLs[i] = clLs.R + c, {clOrd[i], c}
				end
				clLs.R = log2(clLs.R)
				table_sort(clLs, function(a, b) return a[1] < b[1] end)
				local trees = ansdecode(reader, hLit + hDist, generateDecodeTable(clLs))
				Ls, distLs = {R = 0}, {R = 0}
				for i = 1, hLit do Ls[i] = {i - 1, code(trees[i])} end
				for i = 1, hDist do distLs[i] = {i - 1, code(trees[i+hLit])} end
				for i = 1, hLit do Ls.R = Ls.R + Ls[i][2] end
				for i = 1, hDist do distLs.R = distLs.R + distLs[i][2] end
				Ls.R, distLs.R = log2(Ls.R), log2(distLs.R)
			end
			local sym = ansdecode(reader, 1e10, generateDecodeTable(Ls), generateDecodeTable(distLs))
			for i = 1, #sym do sym[i] = string_char(sym[i]) end
			retval = retval .. table_concat(sym)
		elseif typ == 3 then
			local chars = {}
			while true do
				local len = reader(9)
				if len == 511 then break
				elseif len >= 256 then
					len = len - 253
					local dist = reader(15)
					for _ = 1, len do chars[#chars+1] = chars[#chars - dist] end
				else
					chars[#chars+1] = string.char(len)
				end
			end
			retval = retval .. table.concat(chars)
		else error("invalid chunk") end
	until final
	return retval
end

local function bitstream()
	return setmetatable({data = "", partial = 0, len = 0}, {__call = function(self, bits, len)
		if not bits then bits, len = 0, 8 - self.len end
		assert(bits < 2^len, debug.traceback())
		self.partial = bit32.bor(bit32.lshift(self.partial, len), bits)
		self.len = self.len + len
		while self.len >= 8 do
			local byte = bit32.extract(self.partial, self.len - 8, 8)
			self.data = self.data .. string.char(byte)
			self.len = self.len - 8
		end
	end})
end

local function encoder(Ls, symbols)
	local R = Ls.R
	if R == 0 then
		if symbols then return 0 end
		while coroutine.yield(0, 0) do end
		return 0, 0
	end
	local L = 2^R
	local k, nb, start, next, symbol, order = {}, {}, {}, {}, {}, {}
	local X, step = 0, L < 16 and 3 or 0.625 * L + 3
	local sumLs = 0
	for _, p in ipairs(Ls) do
		local s, v = p[1], p[2]
		k[s] = R - log2(v)
		nb[s] = bit32_lshift(k[s], R+1) - bit32_lshift(v, k[s])
		start[s] = sumLs - v
		next[s] = v
		order[#order+1] = s
		for _ = 1, v do
			while symbol[X] ~= nil do X = (X + 1) % L end
			symbol[X] = s
			X = (X + step) % L
		end
		sumLs = sumLs + v
	end
	local encodingTable = {}
	for x = L, 2*L - 1 do
		local s = symbol[x - L]
		encodingTable[start[s] + next[s]] = x
		next[s] = next[s] + 1
	end
	local x = L
	local bitcount, nproc = 0, 0
	local f
	if symbols then
		local pos = #symbols
		function f()
			local s = symbols[pos]
			pos = pos - 1
			return s
		end
	else f = coroutine.yield end
	local s = f()
	while s do
		local nbBits = bit32_rshift(x + nb[s], R + 1)
		local nexts = f(bit32_band(x, 2^nbBits-1), nbBits)
		bitcount = bitcount + nbBits
		nproc = nproc + 1
		x = encodingTable[start[s] + bit32_rshift(x, nbBits)]
		s = nexts
	end
	if not symbols then
		print("Size of block:", bitcount + R, nproc)
		return x - L, R
	else
		return bitcount + R
	end
end

local function coroutine_resume(coro, ...)
	local res = table.pack(coroutine.resume(coro, ...))
	if not res[1] then error(debug.traceback(coro, res[2]), 2) end
	return table.unpack(res, 1, res.n)
end

local function encodeLZ(symbols, Ls, distLs, out)
	local bitbuf = {}
	local symcoder = coroutine.create(encoder)
	coroutine_resume(symcoder, Ls)
	local lzcoder = coroutine.create(encoder)
	coroutine_resume(lzcoder, distLs)
	for i = #symbols, 1, -1 do
		local s = symbols[i]
		if type(s) == "table" then
			bitbuf[#bitbuf+1] = {select(2, coroutine_resume(symcoder, s[1].code + 257))}
			bitbuf[#bitbuf+1] = {select(2, coroutine_resume(lzcoder, s[2].code))}
			bitbuf[#bitbuf+1] = {s[2].extra, s[2].bits}
			bitbuf[#bitbuf+1] = {s[1].extra, s[1].bits}
		else
			bitbuf[#bitbuf+1] = {select(2, coroutine_resume(symcoder, s))}
		end
	end
	bitbuf[#bitbuf+1] = {select(2, coroutine_resume(lzcoder))}
	bitbuf[#bitbuf+1] = {select(2, coroutine_resume(symcoder))}
	for i = #bitbuf, 2, -1 do out(bitbuf[i][1], bitbuf[i][2]) end
end

local function sizeLZ(symbols, Ls, distLs)
	if not Ls or not distLs then return math.huge end
	local newsym, distsym = {}, {}
	local bits = 0
	for i, s in ipairs(symbols) do
		if type(s) == "table" then
			newsym[i] = s[1].code + 257
			distsym[#distsym+1] = s[2].code
			bits = bits + s[1].bits + s[2].bits
		else
			newsym[i] = s
		end
	end
	return bits + encoder(Ls, newsym) + encoder(distLs, distsym)
end

local function encodeDict(symbols, Ls, out)
	local bitbuf = {}
	local symcoder = coroutine.create(encoder)
	coroutine.resume(symcoder, Ls)
	for i = #symbols, 1, -1 do
		local s = symbols[i]
		if type(s) == "table" then
			bitbuf[#bitbuf+1] = {select(2, coroutine.resume(symcoder, s[1]))}
			if s[1] == 16 then bitbuf[#bitbuf+1] = {s[2], 2}
			elseif s[1] == 17 then bitbuf[#bitbuf+1] = {s[2], 3}
			elseif s[1] == 18 then bitbuf[#bitbuf+1] = {s[2], 7} end
		else
			bitbuf[#bitbuf+1] = {select(2, coroutine.resume(symcoder, s))}
		end
	end
	bitbuf[#bitbuf+1] = {select(2, coroutine.resume(symcoder))}
	for i = #bitbuf, 1, -1 do out(bitbuf[i][1], bitbuf[i][2]) end
end

local function sizeDict(symbols, Ls)
	if not Ls then return math.huge end
	local newsym = {}
	local bits = 0
	for i, s in ipairs(symbols) do
		if type(s) == "table" then
			newsym[i] = s[1]
			if s[1] == 16 then bits = bits + 2
			elseif s[1] == 17 then bits = bits + 3
			elseif s[1] == 18 then bits = bits + 7 end
		else
			newsym[i] = s
		end
	end
	return bits + encoder(Ls, newsym)
end

local function distcode(i)
	if i == 0 or i == 1 then return {code = i, extra = 0, bits = 0, raw = i} end
	local ebits = math.max(select(2, math.frexp(i)) - 2, 0)
	local mask = 2^ebits
	return {code = ebits * 2 + (bit32.btest(i, mask) and 3 or 2), extra = bit32.band(i, mask-1), bits = ebits, raw = i}
end

local function lencode(i)
	if i >= 0 and i < 4 then return {code = i, extra = 0, bits = 0, raw = i} end
	local ebits = math.max(select(2, math.frexp(i)) - 3, 0)
	local mask = 2^ebits
	return {code = ebits * 4 + (bit32.btest(i, mask) and 5 or 4) + (bit32.btest(i, mask*2) and 2 or 0), extra = bit32.band(i, mask-1), bits = ebits, raw = i}
end

local function lz77(tokens, maxdist)
	maxdist = math_min(maxdist or 1024, 32768)
	local retval = {}
	local lookback = {}
	local i = 1
	while i <= #tokens do
		local v = tokens[i]
		if lookback[v] then
			local lblist = lookback[v]
			local max, pos = 0
			for n = #lblist, 1, -1 do
				local l = lblist[n]
				if i - l > maxdist then break end
				for j = 1, math_min(#tokens - i, 129) do
					local lj = (j - 1) % (i - l) + 1
					if tokens[i+j] == tokens[l+lj] then
						if j > max then max, pos = j, l end
					else break end
				end
			end
			if max >= 2 then
				local len = lencode(max - 2)
				local dist = distcode(i - pos - 1)
				retval[#retval+1] = {len, dist}
				for j = 0, max do
					v = tokens[i+j]
					lookback[v][#lookback[v]+1] = i+j
				end
				i = i + max + 1
				v = nil
			end
		end
		if v then
			retval[#retval+1] = v
			lookback[v] = lookback[v] or {}
			lookback[v][#lookback[v]+1] = i
			i = i + 1
		end
	end
	return retval
end

local function leafcomp(h) return function(a, b)
	if a.height > h then return true end
	if b.height > h then return false end
	return a.weight > b.weight
end end
local function sortcodes(symbolMap)
	if symbolMap then return function(a, b) if a.bits == b.bits then return symbolMap[a.symbol] < symbolMap[b.symbol] else return a.bits < b.bits end end
	else return function(a, b) if a.bits == b.bits then return a.symbol < b.symbol else return a.bits < b.bits end end end
end

local function loadcodes(node, codes, map, partial)
	if node.data then
		partial.symbol = node.data
		map[node.data] = partial
		codes[#codes+1] = partial
	else
		loadcodes(node[1], codes, map, {bits = partial.bits + 1, code = partial.code * 2})
		loadcodes(node[2], codes, map, {bits = partial.bits + 1, code = partial.code * 2 + 1})
	end
end

local function makeLs(freq, maxHeight)
	maxHeight = maxHeight or 15
	local Ls = {R = 0}
	for k, v in pairs(freq) do Ls[#Ls+1] = {k, v} end
	table_sort(Ls, function(a, b) return a[1] < b[1] end)
	local queue = {}
	for i, v in ipairs(Ls) do if v[2] > 0 then queue[#queue+1] = {data = v[1], weight = v[2], height = 1} end end
	if #queue < 2 then
		local retval = {R = 0}
		for i, v in ipairs(Ls) do if v[1] == queue[1].data then retval[i] = {v[1], 1, 0} end end
		return retval
	end
	local comp = leafcomp(maxHeight - 1)
	table_sort(queue, comp)
	while #queue > 1 do
		local a, b = queue[#queue-1], queue[#queue]
		local n = {weight = a.weight + b.weight, height = math_max(a.height + 1, b.height + 1), a, b}
		queue[#queue] = nil
		queue[#queue] = n
		table_sort(queue, comp)
	end
	local codes, map = {}, {}
	loadcodes(queue[1], codes, map, {bits = 0, code = 0})
	table_sort(codes, sortcodes())
	codes[1].code = 0
	for i = 2, #codes do codes[i].code = bit32.lshift(codes[i-1].code + 1, codes[i].bits - codes[i-1].bits) end
	local lengths = {}
	for i, v in ipairs(Ls) do
		lengths[i] = map[v[1]] and map[v[1]].bits or 0
		Ls.R = math_max(Ls.R, lengths[i])
	end
	local LsH = {}
	local huffSum = 0
	for i, v in ipairs(lengths) do assert(v > 0 and v <= maxHeight) LsH[i] = {Ls[i][1], 2^(Ls.R-v), Ls.R-v} huffSum = huffSum + 2^(Ls.R-v) end
	LsH.R = select(2, math.frexp(huffSum))-1
	return LsH
end

local function deflate(data, level, forceStatic)
	if data == "" then return "\x80\x00\x00\xFF\xFF" end
	level = level or 5
	local out = bitstream()
	for i = 1, #data, 65536 do
		print(#out.data, out.len)
		local final = i + 65536 > #data
		local chunk = {}
		for j = 0, math_min(#data - i, 65535) do
			chunk[j+1] = data:byte(i+j)
		end
		chunk[#chunk+1] = 256
		local lzchunk = level == 0 and chunk or lz77(chunk, 2^(level + 6))
		local freq, distfreq = {}, {}
		for _, v in ipairs(lzchunk) do
			if type(v) == "table" then
				local s = v[1].code + 257
				freq[s] = (freq[s] or 0) + 1
				distfreq[v[2].code] = (distfreq[v[2].code] or 0) + 1
			else
				freq[v] = (freq[v] or 0) + 1
			end
		end
		local dynamicLs = makeLs(freq)
		local dynamicDistLs = makeLs(distfreq)
		local lengths = {}
		for j = 0, 285 do
			local found = false
			for _, v in ipairs(dynamicLs) do
				if v[1] == j then
					found = true
					lengths[j] = v[3] + 1
					break
				end
			end
			if not found then lengths[j] = 0 end
		end
		while #lengths > 256 and lengths[#lengths] == 0 do lengths[#lengths] = nil end
		local hLit = #lengths - 256
		for j = 0, 31 do
			local found = false
			for _, v in ipairs(dynamicDistLs) do
				if v[1] == j then
					found = true
					lengths[#lengths+1] = v[3] + 1
					break
				end
			end
			if not found then lengths[#lengths+1] = 0 end
		end
		while #lengths > 257 and lengths[#lengths] == 0 do lengths[#lengths] = nil end
		local hDist = #lengths - hLit - 257
		local lencodes = {}
		do
			local j = 0
			while j <= #lengths do
				if lengths[j] == lengths[j+1] and lengths[j+1] == lengths[j+2] then
					if lengths[j] == 0 then
						local len = 3
						while lengths[j+len] == 0 and len < 138 do len = len + 1 end
						if len >= 11 then lencodes[#lencodes+1] = {18, len - 11}
						else lencodes[#lencodes+1] = {17, len - 3} end
						j = j + len
					elseif lengths[j+2] == lengths[j+3] then
						local len = 4
						while lengths[j+len] == lengths[j] and len < 7 do len = len + 1 end
						lencodes[#lencodes+1] = lengths[j]
						lencodes[#lencodes+1] = {16, len - 4}
						j = j + len
					else
						lencodes[#lencodes+1] = lengths[j]
						lencodes[#lencodes+1] = lengths[j]
						lencodes[#lencodes+1] = lengths[j]
						j = j + 3
					end
				else
					lencodes[#lencodes+1] = lengths[j]
					j = j + 1
				end
			end
		end
		freq = {}
		for _, v in ipairs(lencodes) do
			if type(v) == "table" then freq[v[1]] = (freq[v[1]] or 0) + 1
			else freq[v] = (freq[v] or 0) + 1 end
		end
		local lencodeLs = makeLs(freq, 7)
		local lencodelen = {}
		for j, v in ipairs(clOrd) do
			local l = 0
			for _, w in ipairs(lencodeLs) do
				if w[1] == v then
					l = w[3] + 1
					break
				end
			end
			write(l .. " ")
			lencodelen[j] = l
		end
		print()
		while #lencodelen > 4 and lencodelen[#lencodelen] == 0 do lencodelen[#lencodelen] = nil end
		local uncompSize = #chunk * 8 + 8
		local lzssSize = #lzchunk * 9
		for _, v in ipairs(lzchunk) do if type(v) == "table" then lzssSize = lzssSize + 15 end end
		local staticSize = sizeLZ(lzchunk, staticLs, staticDistLs)
		local dynamicSize = forceStatic and math.huge or (sizeLZ(lzchunk, dynamicLs, dynamicDistLs) + sizeDict(lencodes, lencodeLs) + #lencodelen * 3)
		local minSize = math_min(uncompSize, lzssSize, staticSize, dynamicSize)
		print("Sizes:", uncompSize, lzssSize, staticSize, dynamicSize)
		out(final and 1 or 0, 1)
		if minSize == uncompSize then
			print("Writing uncompressed block", uncompSize)
			out(0, 2)
			out()
			out(#chunk - 1, 16)
			out(bit32.band(bit32.bnot(#chunk - 1), 0xFFFF), 16)
			out.data = out.data .. data:sub(i, i + 65535)
		elseif minSize == lzssSize then
			print("Writing LZSS block", lzssSize)
			out(3, 2)
			for _, s in ipairs(lzchunk) do
				if type(s) == "table" then
					out(s[1].raw + 256, 9)
					out(s[2].raw, 15)
				elseif s == 256 then
					out(511, 9)
				else
					out(s, 9)
				end
			end
		else
			local Ls, distLs
			if minSize == staticSize then
				print("Writing static block", staticSize)
				out(1, 2)
				Ls, distLs = staticLs, staticDistLs
			else
				print("Writing dynamic block", dynamicSize)
				out(2, 2)
				Ls, distLs = dynamicLs, dynamicDistLs
				out(hLit, 5)
				out(hDist, 5)
				out(#lencodelen - 4, 4)
				for _, v in ipairs(lencodelen) do out(v, 3) end
				encodeDict(lencodes, lencodeLs, out)
			end
			encodeLZ(lzchunk, Ls, distLs, out)
		end
	end
	out()
	return out.data
end

Box.compress = deflate
Box.decompress = inflate

return Box
