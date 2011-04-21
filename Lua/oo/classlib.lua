
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


