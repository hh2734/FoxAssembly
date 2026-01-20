-- Error in library: fxas.string >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768584598
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.string", -- Your package name
	version = 1.0, -- fxas.string version
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

local function upper(str) return str:gsub("([a-zа-яё])", function(c) return string.char(string.byte(c) -(c == "ё" and 16 or 32)) end) end
local function lower(str) return str:gsub("([A-ZА-ЯЁ])", function(c) return string.char(string.byte(c) +(c == "ё" and 16 or 32)) end) end

function Box.insert(STR, implant, pos)
	if pos == nil then
		return STR .. implant
	end
	return STR:sub(1, pos - 1) .. implant .. STR:sub(pos)
end

function Box.extract(STR, pattern)
	STR = STR:gsub(pattern, "")
	return STR
end

local function array(STR)
	local array = {}
	for s in STR:gmatch(".") do
		array[#array + 1] = s
	end
	return array
end

function Box.isdigit(STR)
	return STR:find("%D") == nil
end

local function isAlpha(STR)
	return STR:find("[%d%p]") == nil
end

function Box.split(STR, sep, plain)
	local result = {}
	local pos = 1
	sep = sep or " "
	if sep == "" then
		for i = 1, #STR do
			result[i] = STR:sub(i, i)
		end
	else
		while pos <= #STR do
			local s, f = STR:find(sep, pos, plain)
			if s then
				table.insert(result, STR:sub(pos, s - 1))
				pos = f + 1
			else
				table.insert(result, STR:sub(pos))
				break
			end
		end
	end
	return result
end

function Box.isspace(STR)
	return STR:find("^[%s%c]*$") ~= nil
end

function Box.isupper(STR)
	return upper(STR) == STR
end

function Box.islower(STR)
	return lower(STR) == STR
end

function Box.istitle(STR)
	local p = STR:find("[A-zА-яЁё]")
	local let = STR:sub(p, p)
	return let == upper(let)
end

function Box.starts(STR, str)
	return STR:sub(1, #str) == prefix
end

function Box.ends(STR, str)
	return STR:sub(-#str) == str
end

function Box.capitalize(STR)
	STR = STR:gsub("^.", upper)
	return STR
end

function Box.uncapitalize(STR)
	STR = STR:gsub("^.", lower)
	return STR
end

function Box.tabs_to_space(STR, count)
	local spaces = (" "):rep(count or 4)
	STR = STR:gsub("\t", spaces)
	return STR
end

function Box.space_to_tabs(STR, count)
	local spaces = (" "):rep(count or 4)
	STR = STR:gsub(spaces, "\t")
	return STR
end

function Box.center(STR, width, char)
	char = char or " "
    local len = #STR
    if len >= width then
        return STR
    end
    local pad_total = width - len
    local pad_left = math.floor(pad_total / 2)
    local pad_right = pad_total - pad_left
    return string.rep(char, pad_left) .. STR .. string.rep(char, pad_right)
end

function Box.count(STR, search, p1, p2)
	local area = STR:sub(p1 or 1, p2 or #STR)
	local count, pos = 0, p1 or 1
	repeat
		local s, f = area:find(search, pos, true)
		count = s and count + 1 or count
		pos = f and f + 1
	until pos == nil
	return count
end

function Box.trimend(STR)
	STR = STR:gsub("%s*$", "")
	return STR
end

function Box.trimstart(STR)
	STR = STR:gsub("^%s*", "")
	return STR
end

function Box.trim(STR)
	STR = STR:match("^%s*(.-)%s*$")
	return STR
end

function Box.swapcase(STR)
	local result = {}
	local str
	for s in STR:gmatch(".") do
		str = s
		if isAlpha(str) then
			k = isLower(a) and upper(str) or lower(str)
		end
		result[#result + 1] = str
		str = nil
	end
	return table.concat(result)
end

function Box.splitequally(STR, width)
	assert(width > 0, "Width less than zero")
	if width >= STR:len() then
		return { STR }
	end

	local result, i = {}, 1
	repeat
		if #result == 0 or #result[#result] >= width then
			result[#result + 1] = ""
		end
		result[#result] = result[#result] .. STR:sub(i, i)
		i = i + 1
	until i > #STR
	return result
end

function Box.rfind(STR, pattern, pos, plain)
	local i = pos or #STR
	repeat
		local result = { STR:find(pattern, i, plain) }
		if next(result) ~= nil then
			return table.unpack(result)
		end
		i = i - 1
	until i <= 0
	return nil
end

function Box.wrap(STR, width)
	assert(width > 0, "Width less than zero")
	if width < STR:len() then
		local pos = 1
		STR = STR:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
			if fi - pos > (width or 72) then
				pos = st
				return "\n" .. word
			end
		end)
	end
	return STR
end

local function levDist(STR, str)
	if #STR == 0 then
		return #str
	elseif #str == 0 then
		return #STR
	elseif STR == str then
		return 0
	end

	local cost = 0
	local matrix = {}
	for i = 0, #STR do
		matrix[i] = {}; matrix[i][0] = i
	end
	for i = 0, #str do matrix[0][i] = i end
	for i = 1, #STR, 1 do
		for j = 1, #str, 1 do
			cost = STR:byte(i) == str:byte(j) and 0 or 1
			matrix[i][j] = math.min(
				matrix[i - 1][j] + 1,
				matrix[i][j - 1] + 1,
				matrix[i - 1][j - 1] + cost
			)
		end
	end
	return matrix[#STR][#str]
end

function Box.similarity(STR, str)
	local dist = levDist(STR, str)
	return 1 - dist / math.max(#STR, #str), dist
end

function Box.camel(STR)
	local arr = array(STR)
	for i, let in ipairs(arr) do
		arr[i] = (i % 2 == 0) and lower(let) or upper(let)
	end
	return table.concat(arr)
end

function Box.regescape(STR)
	return (STR:gsub("(%W)", "%%%1"))
end

function Box.shuffle(STR, seed)
	local time = os and os.time or function() return math.random() end
	math.randomseed(seed or clock())
	local arr, new = array(STR), {}
	for i = 1, #arr do
		new[i] = arr[math.random(#arr)]
	end
	return table.concat(new)
end

function Box.cutlimit(STR, max_len, symbol)
	assert(max_len > 0, "Maximum length cannot be less than or equal to 1")
	if #STR > 0 and #STR > max_len then
		symbol = symbol or ".."
		STR = STR:sub(1, max_len) .. symbol
	end
	return STR
end

function Box.switchlayout(STR)
	local result = ""
	local b = STR:find("^[%s%p]*%a") ~= nil
	local t = {
		{ "а", "f" }, { "б", "," }, { "в", "d" },
		{ "г", "u" }, { "д", "l" }, { "е", "t" },
		{ "ё", "`" }, { "ж", ";" }, { "з", "p" },
		{ "и", "b" }, { "й", "q" }, { "к", "r" },
		{ "л", "k" }, { "м", "v" }, { "н", "y" },
		{ "о", "j" }, { "п", "g" }, { "р", "h" },
		{ "с", "c" }, { "т", "n" }, { "у", "e" },
		{ "ф", "a" }, { "х", "[" }, { "ц", "w" },
		{ "ч", "x" }, { "ш", "i" }, { "щ", "o" },
		{ "ь", "m" }, { "ы", "s" }, { "ъ", "]" },
		{ "э", "'" }, { "/", "." }, { "я", "z" },
		{ "А", "F" }, { "Б", "<" }, { "В", "D" },
		{ "Г", "U" }, { "Д", "L" }, { "Е", "T" },
		{ "Ё", "~" }, { "Ж", ":" }, { "З", "P" },
		{ "И", "B" }, { "Й", "Q" }, { "К", "R" },
		{ "Л", "K" }, { "М", "V" }, { "Н", "Y" },
		{ "О", "J" }, { "П", "G" }, { "Р", "H" },
		{ "С", "C" }, { "Т", "N" }, { "У", "E" },
		{ "Ф", "A" }, { "Х", "{" }, { "Ц", "W" },
		{ "Ч", "X" }, { "Ш", "I" }, { "Щ", "O" },
		{ "Ь", "M" }, { "Ы", "S" }, { "Ъ", "}" },
		{ "Э", "\"" }, { "Ю", ">" }, { "Я", "Z" }
	}
	local str
	for l in STR:gmatch(".") do
		str = l
		local fined = false
		for _, v in ipairs(t) do
			if str == v[b and 2 or 1] then
				str = v[b and 1 or 2]
				fined = true
				break
			end
		end
		if not fined then
			for _, v in ipairs(t) do
				if str == v[b and 1 or 2] then
					str = v[b and 2 or 1]
					break
				end
			end
		end
		result = (result .. str)
		str = nil
	end
	return result
end

Box.upper = upper
Box.lower = lower
Box.isalpha = isAlpha
Box.array = array
Box.levdist = levDist

return Box
