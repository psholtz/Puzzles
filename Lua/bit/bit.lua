#!./lua5.1

--
-- Maximum number of supported bits.
--
local MAX_BITS = 32

--
-- Make sure we are not doing bitwise operations on floats.
--
local function check_int(n)
	if ( n - math.floor(n) > 0 ) then
		error("trying to use bitwise operations on non-integer!")
	end
end

--
-- Convert the number n to an array of bits.
-- For instance, 4 is changed to { 0,0,1 }, 
-- and 7 is changed to { 1,1,1, }.
--
local function to_bits(n) 
	-- do checks on the argument
	check_int(n)
	if ( n < 0 ) then
		return to_bits( bit.bnot(math.abs(n)) + 1 )	
	end

	-- calculate the bits table
	local tbl = {}
	local cnt = 1
	while ( n > 0 ) do
		local last = math.mod(n,2)
		if ( last == 1 ) then
			tbl[cnt] = 1
		else
			tbl[cnt] = 0
		end
		n = ( n - last ) / 2
		cnt = cnt + 1
	end
	
	return tbl 
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

--
-- Pad the smaller table with "0" and
-- return two tables of the same size.
--
local function expand(tbl_m,tbl_n)
	-- set the large and small tables
	local big = {}
	local small = {}
	if ( table.getn(tbl_m) > table.getn(tbl_n) ) then
		big = tbl_m
		small = tbl_n
	else
		big = tbl_n
		small = tbl_m
	end
	
	-- pad the small table w/ 0s, till its as big as large
	for i=table.getn(small) + 1, table.getn(big) do
		small[i] = 0
	end
end

--
-- Convert n to its logical "NOT".
-- For instance, the number 4, i.e., { 0,0,1,0,... } would
-- be converted to { 1,1,0,1,...}.
--
-- Results are padded out to MAX_BITS.
--
local function bit_not( n )
	-- convert number to bits
	local tbl = to_bits(n)
	
	-- flip-flop each bit to its opposite setting
	local size = math.max( table.getn(tbl), MAX_BITS )
	for i=1,size do
		if ( tbl[i] == 1 ) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end
	
	return tbl_to_number(tbl)
end

-- 
-- Implement bitwise-or operation.
--
local function bit_or( m, n )
	-- convert to bit table and pad the smaller
	local tbl_m = to_bits(m)
	local tbl_n = to_bits(n)
	expand( tbl_m, tbl_n )
	
	-- implement bitwise-or
	local tbl = {}
	local size = math.max( #tbl_m, #tbl_n )
	for i=1,size do
		if ( tbl_m[i] == 0 and tbl_n[i] == 0 ) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end
	 
	return tbl_to_number(tbl)
end

-- 
-- Implement bitwise-and operation.
--
local function bit_and( m, n )
	-- convert to bit table and pad the smaller
	local tbl_m = to_bits(m)
	local tbl_n = to_bits(n)
	expand( tbl_m, tbl_n )
	
	-- implement bitwise-and
	local tbl = {}
	local size = math.max( #tbl_m, #tbl_n )
	for i=1,size do
		if ( tbl_m[i] == 1 and tbl_n[i] == 1 ) then
			tbl[i] = 1
		else
			tbl[i] = 0
		end
	end
	 
	return tbl_to_number(tbl)
end

--
-- Create a library interface.
--
bit = {
	bor = bit_or,
	bnot = bit_not,
	band = bit_and,
}

