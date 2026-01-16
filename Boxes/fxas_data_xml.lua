-- Error in library: fxas.data.xml >
-- FoxBox version: 2.1
-- fox.lua version: 1.0
-- Unix time: 1768585956
-- DocType version: Beta X1
--> ============  METADATA  ============ <--


local Box = {}
Box._config = {
	package = "fxas.data.xml", -- Your package name
	version = 1.0, -- fxas.data.xml version
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

local io, string, pairs = io, string, pairs

local slashchar = string.byte('/', 1)
local E = string.byte('E', 1)

function defaultEntityTable()
	return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
end

function replaceEntities(s, entities)
	return s:gsub('&([^;]+);', entities)
end

function createEntityTable(docEntities, resultEntities)
	local entities = resultEntities or defaultEntityTable()
	for _,e in pairs(docEntities) do
		e.value = replaceEntities(e.value, entities)
		entities[e.name] = e.value
	end
	return entities
end

function parse(s, evalEntities)
	s = s:gsub('<!%-%-(.-)%-%->', '')

	local entities, tentities = {}

	if evalEntities then
		local pos = s:find('<[_%w]')
		if pos then
			s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, _, entity)
				entities[#entities+1] = {name=name, value=entity}
			end)
			tentities = createEntityTable(entities)
			s = replaceEntities(s:sub(pos), tentities)
		end
	end

	local t, l = {}, {}

	local addtext = function(txt)
		txt = txt:match'^%s*(.*%S)' or ''
		if #txt ~= 0 then
			t[#t+1] = {text=txt}
		end
	end

	s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
		if #type == 0 then
			local attrs, orderedattrs = {}, {}
			if #closed == 0 then
				local len = 0
				for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
					len = len + #all
					attrs[aname] = value
					orderedattrs[#orderedattrs+1] = {name=aname, value=value}
					if #starttxt ~= 0 then
						txt = txt:sub(len+1)
						closed = starttxt
						break
					end
				end
			end
			t[#t+1] = {tag=name, attrs=attrs, children={}, orderedattrs=orderedattrs}

			if closed:byte(1) ~= slashchar then
				l[#l+1] = t
				t = t[#t].children
			end

			addtext(txt)
		elseif '/' == type then
			t = l[#l]
			l[#l] = nil

			addtext(txt)
		elseif '!' == type then
			if E == name:byte(1) then
				txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, _, entity)
					entities[#entities+1] = {name=name, value=entity}
				end, 1)
			end
		end
	end)

	return {children=t, entities=entities, tentities=tentities}
end

Box.parse = parse
Box.default_entity_table = defaultEntityTable
Box.replace = replaceEntities
Box.create_entity_table = createEntityTable

return Box
