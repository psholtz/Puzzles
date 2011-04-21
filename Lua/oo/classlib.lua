
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


