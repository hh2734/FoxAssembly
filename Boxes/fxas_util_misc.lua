-- Error in library: fxas.util.misc >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768584435
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.util.misc", -- Your package name
	version = 1.0, -- fxas.util.misc version
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

function Box.mc(arg1, ...)
	for k, v in pairs({...}) do if arg1 == v then return true end end
	return false
end

return Box
