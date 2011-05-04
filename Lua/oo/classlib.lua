
-- =======
-- PRIVATE
-- =======

--[[ 
	Define unique value for identifying ambiguous base objects and inherited
	attributes. Ambiguous values are normally removed from classes and objects,
	but if keep_ambiguous == true they are left there and the ambiguous value
	is made to behave in a way useful for debugging.
]]
local ambiguous

if keep_ambiguous then

	ambiguous = { _type = 'ambiguous' }

	local function invalid(operation)
		return function()
			error('Invalid ' .. operation .. ' on ambiguous')
		end
	end
	
	-- Make ambiguous complain about everything except tostring()
	local ambiguous_mt =
	{
		__add = invalid('addition'),
		__sub = invalid('subtraction'),
		__mul = invalid('multiplication'),
		__div = invalid('division'),
		__mod = invalid('modulus operation'),
		__pow = invalid('exponentiation'),
		__unm = invalid('unary minus'),
		__concat = invalid('concatenation'),
		__len = invalid('length operation'),
		__eq = invalid('equality comparison'),
		__lt = invalid('less than'),
		__le = invalid('less or equal'),
		__index = invalid('indexing'),
		__newindex = invalid('new indexing'),
		__call = invalid('call'),
		__tostring = invalid(''),
		__tonumber = invalid('conversion to number'),
	}
	setmetatable(ambiguous, ambiguous_mt)
end

--[[
	Reserved attribute names
]]
local reserved = 
{
	__index 		= true,
	__newindex 		= true,
	__type 			= true,
	__class 		= true,
	__bases 		= true,
	__inherited 		= true,
	__from 			= true,
	__shared 		= true,
	__user_init 		= true,
	__name 			= true,
	__initialized 		= true
}

--[[
	Some special user-set attributes are renamed
]]
local rename = 
{
	__init 	= '__user_init',
	__set 	= '__user_set',
	__get 	= '__user_get',
}

--[[
	The metatable of all classes, containing:

	To be used by the classes:
		__call()	for creating instances
		__init()	default constructor
		is_a()		for checking object and class types
		implements()	for checking interface support

	To be used internally:
		__newindex()	for controlling class population
]]

local class_mt = {}
class_mt.__index = class_mt

--[[
	This controls class population.
	Here 'self' is a class being populated by inheritance or by the user.
]]
function class_mt:__newindex(name,value)

	-- Rename special user-set attributes
	if rename[name] then name = rename[name] end

	-- __user_get() needs an __index() handler
	if name == '__user_get' then
		self.__index = value and function(obj, k)
			local v = self[k]
			if v == nil and not reserved[k] then v = value(obj, k) end
		end or self

	elseif name == '__user_set' then
		self.__newindex = value and function(obj, k, v)
			if reserved[k] or not value(obj, k, v) then rawset(obj, k, v) end
		end or nil
	end

	-- Assign the attribute
	rawset(self, name, value)
end

--[[
	This function creates an object of a certain class and class itself
	recursively to create one child object for each base class. Base objects
	of unnamed base classes are accessed by using the base class as an index
	into the object, base objects of named base classes are accessed as fields
	of the object with the names of their respective base classes.
	Classes derived in shared mode will create only a single base object.
	Unambiguous grandchildren are inherited by the parent if they do not 
	collide with direct children.
]]

local function build(class, shared_objs, shared)

	-- If shared, look in the repository of shared objects
	-- and return any previous instance of this class.
	if shared then
		local prev_instance = shared_objs[class]
		if prev_instance then return prev_instance end
	end

	-- Create new object
	local obj = { __type = "object" }

	-- Build child objects if there are base classes
	local nbases = #class.__bases
	if nbases > 0 then
		
		-- Repository for storing inherited base objects
		local inherited = {}

		-- List of ambiguous keys
		local ambiguous_keys = {}

		-- Build child objects for each base class
		for i=1, nbases do
			local base = class.__bases[i]
			local child = build(base, shared_objs, class.__shared[base])
			obj[base.__name] = child

			-- Get inherited grandchildren from this child
			for c, grandchild in pairs(child) do
			
				-- We can only accept one inherited grandchild of each class, 
				-- otherwise this is an ambiguous reference
				if not ambiguous_keys[c] then
					if not inherited[c] then inherited[c] = grandchild
					elseif inherited[c] ~= grandchild then
						inherited[c] = ambiguous
						table.insert(ambiguous_keys, c)
					end
				end
			end
		end

		-- Accept inherited grandchildren if they don't collide with direct children
		for k, v in pairs(inherited) do
			if not obj[k] then obj[k] = v end
		end
	end

	-- Object is ready
	setmetatable(obj, class)

	-- If shared, add it to the repository of shared objects
	if shared then shared_objs[class] = obj end
	
	return obj
end

--[[
	The __call() operator creates an instance of the class and initializes it.
]]
function class_mt:__call(...)
	local obj = build(self, {}, false)
	obj:__init(...)
	return obj
end

--[[ 
	The implements() method checks that an object or class supports the
	interface of a target class. This means it can be passed as an argument to
	any function that expects the target class. We consider only functions
	and callable objects to be part of the interface of a class.
]]
function class_mt:implements(class)
	-- Auxiliary function to determine if something is callable
	local function is_callable(v)
		if v == ambiguous then return false end
		if type(v) == 'function' then return true end
		local mt = getmetatable(v)
		return mt and type(mt.__call) == 'function'
	end

	-- Check whether we have all the target's callables (except reserved names)
	for k, v in pairs(class) do
		if not reserved[k] and is_callable(v) and not is_callable(self[k]) then
			return false
		end
	end
	return true
end

--[[
	The is_a() method checks the type of an object or class starting from
	its class and following the derivation chain upwards looking for 
	the target class. If the target class is found, it checks that its
	interface is supported (this may fail in multiple inheritance because
	of ambiguities).
]]
function class_mt:is_a(class)
	-- If our class is the target class this is trivially truer
	if self.__class == class then return true end

	-- Auxiliary function to determine if a target class is one of a list of
	-- classes or one of their bases
	local function find(target, classlist)
		for i = 1, #classlist do
			local class = classlist[i]
			if class == target or find(target, class.__bases) then
				return true
			end
		end	
		return false
	end

	-- Check that we derive from the target
	if not find(class, self.__bases) then return false end

	-- Check that we implement the target's interface.
	return self:implements(class)
end

--[[
	Factory-supplied constructor, calls the user-supplied constructor, if any, 
	then calls the constructors of the bases to initialize those that were 
	not initialized before. Objects are initialized exactly once.
]]
function class_mt:__init(...)
	if self.__initialized then return end
	if self.__user_init then self:__user_init(...) end

	for i = 1, #self.__bases do 
		local base = self.__bases[i]
		self[base.__name]:__init(...)
	end
	self.__initialized = true
end

-- PUBLIC

--[[
	Utility type and interface checking functions
]]
function typeof(value)
	local t = type(value)
	return t == 'table' and value.__type or t
end

function classof(value)
	local t = type(value)
	return t == 'table' and value.__class or nil
end

function classname(value)
	if not classof(value) then return nil end
	local name = value.__name
	return type(name) == 'string' and name or nil
end

function implements(value, class)
	return classof(value) and value:implements(class) or false
end
