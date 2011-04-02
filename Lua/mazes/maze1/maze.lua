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
		_mt.grid[j] = {}
		for i=1,_mt.width do
			_mt.grid[j][i] = 0	
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
			if ( bit.band(self.grid[j][i],S) ~= 0 ) then
				out = out .. " "
			else
				out = out .. "_"
			end

			if ( bit.band(self.grid[j][i],E) ~= 0 ) then
				if ( bit.band(bit.bor(self.grid[j][i],self.grid[j][i+1]),S) ~= 0 ) then
					out = out .. " "
				else
					out = out .. "_"
				end
			else
				out = out .. "|"
			end
		end
		table.insert(lines,out)
	end

	-- output maze metadata
	out = "[arg]" .. " " .. self.width .. " " .. self.height .. " " .. self.seed
	table.insert(lines,out)

	print(table.concat(lines,"\r\n"))

end

maze = Maze:new(20)
maze:draw()
