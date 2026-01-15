local fox = {}

fox._VERSION = 1.0

local printr
local path

local function err(text)
	print(text)
	if os then os.exit() else error() end
end

local sysfox

cfg = _G._config
do
	path = cfg.path
	
	local ok
	local file = io.open(path.."/sysfox.lua")
	if not file then err("\n\nCan't find SYSFOX.LUA!\nWrong _config.path?\n") end
	local _data = file:read("*a")
	ok, sysfox = pcall(load(_data))
	if not ok then err("Error loading SYSFOX.LUA!\nError: "..sysfox) end
	
	fox.printr = sysfox.printr
	
	local deps = {}
	local included = {[cfg.package] = true}
	local function include(config, processing)
		local processing = processing or {}
	
		for package, args in pairs(config.deps) do
			--print("current dep - '"..package.."'", "for '"..config.package.."'")
		
			if args and type(args) ~= "table" then 
				err("\n\nWrong _config.deps! (type ~= 'table')\n") 
			end
			
			if processing[package] then
				goto continue
			end
			
			if included[package] then 
				goto continue 
			end
			
			processing[package] = true
			
			local name = package:gsub("%.", "_")
			local dep, ok, filename = sysfox.load(path..".Boxes", name, true)
			local ok_v, _
			
			if ok and type(args[1]) ~= "table" then
				if args[1] == "~=" then
					_, ok_v = sysfox.safeload("return not ("..dep._config.version..(args[2] or "")..")", true)
				else
					_, ok_v = sysfox.safeload("return "..dep._config.version..(args[1] or "")..(args[2] or ""), true)
				end
				if not ok_v then 
					err("\n\nWrong module version:\n"..package.." - "..dep._config.version.."\nExpected: "..args[1].." "..args[2].."\n") 
				end
				
				do
					local f = io.open(filename)
					deps[package] = f:read("*a")
					f:close()
				end
				
				included[package] = true
				if dep._config.deps then 
					include(dep._config, processing) 
				end
			elseif ok and type(args[1]) == "table" then
				for k, v in pairs(args) do
					if v[1] == "~=" then
						_, ok_v = sysfox.safeload("return not ("..dep._config.version..(v[2] or "")..")", true)
					else
						_, ok_v = sysfox.safeload("return "..dep._config.version..(v[1] or "")..(v[2] or ""), true)
					end
					if not ok_v then 
						err("\n\nWrong package version:\n"..package.." - "..dep._config.version.."\nExpected: "..v[1].." "..v[2].."\n") 
					end
					included[package] = true
					do
						local f = io.open(filename)
						deps[package] = f:read("*a")
						f:close()
					end
					if dep._config.deps then 
						include(dep._config, processing) 
					end
				end
			elseif type(dep) == "string" and not ok then
				err("\n\n"..config.package..": Error!\nCan't load '"..package.."'!\n\nError text:\n"..dep.."\n\nYou can try to fix it!")
			end
			
			processing[package] = nil
			::continue::
		end
	end
	if cfg.deps then
		include(cfg)
	end
		
	FoxRAM = sysfox.load(path, "FoxRAM")
		
	FoxRAM.folder("packages")

	for k, dep in pairs(deps) do
		if not dep then print(dep) end
		FoxRAM.file("packages/"..k, dep, "const")
	end

	fox.import = sysfox.import
end

return fox
