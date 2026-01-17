-- Error in library: fxas.crypto.box >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768658888
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.crypto.box", -- Your package name
	version = 1.0, -- fxas.crypto.box version
	deps = {
		["fxas.crypto.salsa20"] = {">=", 1.0},
		["fxas.crypto.ec25519"] = {">=", 1.0},
		["fxas.crypto.poly1305"] = {">=", 1.0}
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

syslib.import("fxas.crypto.salsa20", "salsa20")
syslib.import("fxas.crypto.ec25519", "ec25519")
syslib.import("fxas.crypto.poly1305", "poly1305")

local function public_key(sk)
    assert(type(sk) == "string", "sk must be a string")
    assert(#sk == 32, "#sh must be 32")
    sk = table.pack(sk:byte(1, 32))
    local pk = {}
    ec25519.crypto_scalarmult_base(pk, sk)
    return string.char(table.unpack(pk))
end

local function unpack_nonce(nonce)
    assert(#nonce == 24, "#nonce must be 24")
    local nonce1 = nonce:sub(1, 8)
    local counter = string.unpack("<I8", nonce:sub(9, 16))
    local nonce2 = nonce:sub(17, 24)
    return counter, nonce1, nonce2
end

local function secretbox(pt, nonce, key)
    assert(#key == 32, "#key must be 32")
    local counter, nonce1, nonce2 = unpack_nonce(nonce)
    local key2 = salsa20.hsalsa20(key, counter, nonce1)
    local et = salsa20.encrypt(key2, 0, nonce2, string.rep("\0", 32) .. pt)
    local key3 = et:sub(1, 32)
    et = et:sub(33)
    local mac = poly1305.auth(et, key3)
    return mac .. et
end

local function secretbox_open(et, nonce, key)
    assert(#key == 32, "#key must be 32")
    assert(#et >= 16, "#et must be at least 16")
    local counter, nonce1, nonce2 = unpack_nonce(nonce)
    local key2 = salsa20.hsalsa20(key, counter, nonce1)
    local key3 = salsa20.stream(key2, 0, nonce2, 32)
    local mac = et:sub(1, 16)
    local mac2 = poly1305.auth(et:sub(17), key3)
    if mac2 ~= mac then return nil, "invalid MAC" end
    local pt = salsa20.encrypt(key2, 0, nonce2, string.rep("\0", 16) .. et)
    return pt:sub(33)
end

local function stream_key(pk, sk)
    assert(#pk == 32, "#pk must be 32")
    assert(#sk == 32, "#pk must be 32")
    pk = table.pack(pk:byte(1, 32))
    sk = table.pack(sk:byte(1, 32))
    local k = {}
    ec25519.crypto_scalarmult(k, sk, pk)
    k = string.char(table.unpack(k))
    return salsa20.hsalsa20(k, 0, string.rep("\0", 8))
end

local function box(pt, nonce, pk_b, sk_a)
    return secretbox(pt, nonce, stream_key(pk_b, sk_a))
end

local function box_open(et, nonce, pk_a, sk_b)
    return secretbox_open(et, nonce, stream_key(pk_a, sk_b))
end

Box.public_key = public_key
Box.secretbox = secretbox
Box.secretbox_open = secretbox_open
Box.stream_key = stream_key
Box.box = box
Box.box_open = box_open

return Box
