-- Error in library: fxas.io.file >
-- FoxBox version: 2.13
-- fox.lua version: 1.1
-- Unix time: 1768659161
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.io.file", -- Your package name
	version = 1.0, -- fxas.io.file version
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


function Box.exists(path)
	local file = io.open(path, 'r')
	if file == nil then
		return false
	end
	file:close()
	return true
end

function Box.readfile(path)
	local file = assert(io.open(path, 'r'))
	local content = assert(file:read('*a'))
	file:close()
	return content
end

function Box.writefile(path, content)
	local file = assert(io.open(path, 'w'))
	assert(file:write(content))
	file:close()
end


return Box
