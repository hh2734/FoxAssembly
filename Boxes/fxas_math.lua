-- Error in library: fxas.math >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768584857
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.math", -- Your package name
	version = 1.0, -- fxas.math version
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

function Box.clamp(x, min, max)
	return math.min(math.max(x, min), max)
end

function Box.round(x)
	if x < 0 then
		return math.ceil(x - 0.5)
	else
		return math.floor(x + 0.5)
	end
end

return Box
