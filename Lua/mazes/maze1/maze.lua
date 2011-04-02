#!./lua5.1

--
-- Default arguments
--
local DEFAULT_WIDTH = 10
local DEFAULT_HEIGHT = 10
local DEFAULT_SEED = os.time()

--
-- Imported required files
-- (See other Lua libraries in this branch)
--
dofile "bit.lua"

--
-- Class variables needed for calculations
--
local N,S,E,W = 1,2,4,8
local DX = {}; DX[E] = 1; DX[W] = -1; DX[N] = 0; DX[S] = 0;
local DY = {}; DY[E] = 0; DY[W] = 0; DY[N] = -1; DY[S] = 1;
local OPPOSITE = {};
OPPOSITE[W] = E; OPPOSITE[E] = W; 
OPPOSITE[N] = S; OPPOSITE[S] = N;

Maze = {}
Maze.__index = Maze

function Maze:new(width,height,seed)

	-- configure the metatable
	local _mt = {}
	setmetatable(_mt,Maze)

	-- configure instance variables
	_mt.width = width or DEFAULT_WIDTH 
	_mt.height = height or DEFAULT_HEIGHT 
	_mt.seed = seed or DEFAULT_SEED
	_mt.grid = {}
	for j=1,_mt.height do
		_mt[j] = {}
		for i=1,_mt.width do
			_mt[j][i] = 0	
		end
	end

	math.randomseed(_mt.seed)

	-- return object instance
	return _mt 

end

function Maze:draw()

	-- draw the top line
	lines = {}; out = " ";
	for i=1,self.width*2-1 do
		out = out .. "_"
	end
	table.insert(lines,out)

	-- draw the row of the maze
	for j=1,self.height do
		out = "|"
		for i=1,self.width do
			out = out .. "_"
			out = out .. "|"
		end
		table.insert(lines,out)
	end

	-- output maze metadata
	out = "[arg]" .. " " .. self.width .. " " .. self.height .. " " .. self.seed
	table.insert(lines,out)

	print(table.concat(lines,"\r\n"))

end


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- BITWISE OPERATOR LIBRARY
--
-- Lua does not provide native support for bitwise operations.
-- Hence, we have to create our own methods to provide these 
-- services.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--
-- make sure arg is not float
--
local function check_int(n)
	if ( n - math.floor(n) > 0 ) then
		error("trying to use bitwise operation on a non-integer!")
	end
end

local function to_bits(n)
	check_int(n)
	if ( n < 0 ) then
		-- handle the negative case here
		return to_bits(bit.bnot(math.abs(n))+1)
	end

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
	end

	return tbl 
end

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

local function expand( tbl_n, tbl_m ) 
	local big = {}
	local small = {}
	if ( table.getn(tbl_m) > table.getn(tbl_n) ) then
		big = tbl_m
		small = tbl_n
	else
		big = tbl_n
		small = tbl_m
	end

	for i = table.getn(small), table.getn(big) do
		small[i] = 0
	end
end

--
--  Perform bitwise "not"
--
local function bit_not(n)
	local tbl = to_bits(n)
	local size = math.max(table.getn(tbl),32)
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
-- Perform bitwise "or"
--
local function bit_or(m,n)
	local tbl_m = to_bits(m)
	local tbl_n = to_bits(n)
	expand( tbl_m, tbl_n)

	local tbl = {}
	local rslt = math.max( table.getn(tbl_m), table.getn(tbl_n) )
	for i=1,rslt do
		if ( tbl_m[i] == 0 and tbl_n[i] == 0 ) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end

	return tbl_to_number(tbl) 
end


bit = {
	bor = bit_or,
	bnot = bit_not,
}

maze = Maze:new(20)
maze:draw()
