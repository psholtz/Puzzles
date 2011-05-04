#!./lua5.1

--
-- Default arguments
--
local DEFAULT_WIDTH = 10
local DEFAULT_HEIGHT = 10
local DEFAULT_SEED = os.time()

--
-- Required imported files
-- (see other Lua libs in this branch)
--
dofile "../../bit/bit.lua"		-- provides bitwise operator services
dofile "../../oo/classlib.lua"		-- provides object inheritance services

-- 
-- Constant values needed for calculations
--
local N,S,E,W = 1,2,4,8
local DX = {}; DX[E] = 1; DX[W] = -1; DX[N] = 0; DX[S] = 0;
local DY = {}; DY[E] = 0; DY[W] = 0; DY[N] = -1; DY[S] = 1;
local OPPOSITE = {}
OPPOSITE[W] = E; OPPOSITE[E] = W;
OPPOSITE[N] = S; OPPOSITE[S] = N;

--[[
	Class Maze defines basic behavior to which a maze should conform.
	It provides basic initialization/construction for the maze class,
	and provides a method for drawing ASCII mazes.

	Specific "maze-carving" techniques are implemented in subclasses.
]]
class.Maze()
function Maze:__init(w,h,s)
	
	-- configure instance variables
	self.width = w
	self.height = h
	self.seed = s

	-- seed the PRNG
	math.randomseed(self.seed)

	-- create the maze "grid" itself
	self.grid = {}
	for j = 1, self.height do
		self.grid[j] = {}
		for i = 1, self.width do
			self.grid[j][i] = 0
		end
	end

end

--[[
	Draw the grid, starting in the upper-left hand corner.
]]
function Maze:draw()
	
	-- draw the "top" line
	lines = {}; out = " ";
	for i = 1,  2*self.width-1 do
		out = out .. "_"	
	end
	table.insert(lines,out)

	-- draw the rows of the maze
	for j = 1, self.height do
		out = "|"
		for i = 1, self.width do

			-- draw "south" wall
			if ( bit.band(self.grid[j][i],S) ~= 0 ) then
				out = out .. " "
			else
				out = out .. "_"
			end

			-- draw "east" wall
			if ( bit.band(self.grid[j][i],E) ~= 0 ) then
				if ( bit.band( bit.bor( self.grid[j][i], self.grid[j][i+1] ), S ) ~= 0 ) then
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

-- Accessor: width
function Maze:width()
        return self.width
end
-- Accessor: height
function Maze:height()
	return self.height
end
-- Accessor: seed
function Maze:seed()
	return self.seed
end
-- Accessor: grid
function Maze:grid()
	return self.grid
end

--[[
	Class BackTracker implements a simple recursive back-tracking algorithm
	to draw ASCII mazes. The algorithm works as a "depth-first" search
	of the "tree" or "graph" representing the maze.

	A possible optimization might be to implement a "breadth-first" search.
]]
class.BackTracker(Maze)
function BackTracker:__init(w,h,s)

	-- invoke the super constructor
	self.Maze:__init(w,h,s)

	-- carve the maze grid
	self.carve_passage_from(self,1,1)

end

function BackTracker:carve_passage_from(x,y)	
	
	-- randomize the direction array
	directions = { N,S,E,W }
	for i = 4, 2, -1 do
		local r = math.random(i)
		directions[i], directions[r] = directions[r], directions[i]	
	end

	-- step through the randomized directions
	for i = 1, 4 do
		direction = directions[i]
		dx = x + DX[direction]
		dy = y + DY[direction]	
		g = self.grid(self)
		if (dy > 0) and (dy <= self.height(self)) and (dx > 0) and (dx <= self.width(self)) and (g[dy][dx] == 0) then
			g[y][x] = bit.bor( g[y][x], direction )
			g[dy][dx] = bit.bor( g[dy][dx], OPPOSITE[direction] )
			self.carve_passage_from(self,dx,dy)
		end
	end

end

--[[
	Parse command line options
]]
maze = BackTracker(10,10,DEFAULT_SEED)
maze:draw()

