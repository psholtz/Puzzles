#!../lua5.1

--
-- Make sure we are not doing bitwise operations on floats.
--
local function check_int(n)
	if ( n - math.floor(n) > 0 ) then
		error("trying to use bitwise operations on non-integer!")
	end
end

local function to_bits(n) 
	check_int(n)
	if ( n < 0 ) then
		
	end
	return {}
end

--
-- Take an array of binary values, and return the corresponding decimal value.
-- For instance, if tbl is { 1,0,0,1 }, we return 9.
--
-- Binary tables are counted with most-significant bit being in the right-most 
-- position. That is, { 0,0,0,1 } is 8, while { 1,0,0,0 } is 1.
--
local function tbl_to_number(tbl)
	local n = table.getn(tbl)

	local rslt = 0
	local power = 1
	for i=1,n do
		rslt = rslt + tbl[i] * power
		power = power * 2
	end

	return rslt
end

local function bit_not( n )
	local tbl = to_bits(n)
	print(tbl)
	print(#tbl)
	local size = math.max( table.getn(tbl), 32 )
	for i=1,size do
		if ( tbl[i] == 1 ) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end
	print("done")
	return tbl_to_number(tbl)
end

local function bit_or( m, n )
	local tbl_m = to_bits(m)
	local tbl_n = to_bits(n)
	return 2
end

bit = {
	bor = bit_or,
	bnot = bit_not,
}

--print(bit.bor(3,4))
--print(bit.bor(3.1,4.2))
print(bit.bnot(4))
print(bit.bnot(3))
