-- Error in library: fxas.crypto.chachapoly >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768658172
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.chachapoly", -- Your package name
	version = 1.0, -- fxas.crypto.chachapoly version
	deps = {
		["fxas.crypto.chacha20"] = {">=", 1.0},
		["fxas.data.poly1305"] = {">=", 1.0}
	}
}
--> ============   CONFIG   ============ <--


syslib = ...
if type(syslib) ~= "table" then
	return Box
end

--> ============   SYSLIB   ============ <--
--------------------------------------------
--> ============ YOUR CODE: ============ <--

syslib.import("fxas.crypto.chacha20", "chacha20")
syslib.import("fxas.data.poly1305", "poly1305")

local poly_keygen = function(key, nonce)
	local counter = 0
	local m = string.rep('\0', 64)
	local e = chacha20.encrypt(key, counter, nonce, m)
	return e:sub(1, 32)
end

local pad16 = function(s)
	return (#s % 16 == 0) and "" or ('\0'):rep(16 - (#s % 16))
end

local app = table.insert

local encrypt = function(aad, key, iv, constant, plain)
	local mt = {}
	local nonce = constant .. iv
	local otk = poly_keygen(key, nonce)
	local encr = chacha20.encrypt(key, 1, nonce, plain)
	app(mt, aad)
	app(mt, pad16(aad))
	app(mt, encr)
	app(mt, pad16(encr))
	app(mt, string.pack('<I8', #aad))
	app(mt, string.pack('<I8', #encr))
	local mac_data = table.concat(mt)
	local tag = poly1305.auth(mac_data, otk)
	return encr, tag
end

local function decrypt(aad, key, iv, constant, encr, tag)
	local mt = {}
	local nonce = constant .. iv
	local otk = poly_keygen(key, nonce)
	app(mt, aad)
	app(mt, pad16(aad))
	app(mt, encr)
	app(mt, pad16(encr))
	app(mt, string.pack('<I8', #aad))
	app(mt, string.pack('<I8', #encr))
	local mac_data = table.concat(mt)
	local mac = poly1305.auth(mac_data, otk)
	if mac == tag then
		local plain = chacha20.encrypt(key, 1, nonce, encr)
		return plain
	else
		return nil, "auth failed"
	end
end

Box.poly_keygen = poly_keygen
Box.encrypt = encrypt
Box.decrypt = decrypt

return Box
