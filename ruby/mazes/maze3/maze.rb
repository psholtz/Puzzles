#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.01

# ==================================================================
# Class Maze defines basic behavior to which a maze should conform.
# It provides basic initialization/construction for the maze class,
# and provides a method for drawing ASCII mazes.
#
# Specific "maze-carving" techniques are implemented in subclasses.
# ==================================================================
class Maze
	@@N, @@S, @@E, @@W = 1, 2, 4, 8
	@@OPPOSITE = { @@E => @@W, @@W => @@E, @@N => @@S, @@S => @@N }

	def self.N; @@N; end
	def self.S; @@S; end
	def self.E; @@E; end
	def self.W; @@W; end
	def self.OPPOSITE; @@OPPOSITE; end

	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED )
		@width = w
		@height = h
		@seed = s

		srand(@seed)

		@grid = Array.new(h) { Array.new(w,0) }
	end

	attr_reader :width, :height, :seed

	def draw
		#
		# Draw the "top" line
		#
		puts " " + "_" * (@width * 2 - 1)

		#	
		# Draw each of the rows.
		#
		@height.times do |y|
			print "|"
			@width.times do |x|
				# render "bottom" using "S" switch
				print ( (@grid[y][x] & @@S != 0) ? " " : "_" )
			
				# render "side" using "E" switch	
				if @grid[y][x] & @@E != 0
					print ( ( (@grid[y][x] | @grid[y][x+1]) & @@S != 0 ) ? " " : "_" )
				else
					print "|"
				end
			end
			puts
		end

		#
		# Output maze metadata.
		#
		puts "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
	end
end

# =================================================================================================
# Use randomized variant of Prim's algorithm to generate a maze.
# 
# The algorithm is implemented as follows:
# 
# (1) Randomly select a grid point, and add it to the maze.
# (2) Update the set of "frontier" cells (i.e., cells not in the maze, but which border the maze).
# (3) Randomly select a "frontier" cell, and add it to the maze.
# (4) "Knock down" the wall between these two cells.
# (5) Go back to Step 2, and repeat until there are no more frontier cells.
# =================================================================================================
class Prim < Maze

	# +++++++++++++++++++++++++++
	# Configure class variables.
	# +++++++++++++++++++++++++++
	@@IN = 0x10
	@@FRONTIER = 0x20

	def self.IN; @@IN; end
	def self.FRONTIER; @@FRONTIER; end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Initialize a new 2D maze with the given width and height.
	#
	# Default seed values will give "random" behavior.
	# User-supplied seed value will give "deterministic" behavior.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE, d=DEFAULT_DELAY )
		# 
		# Invoke super-constructor
		#
		super(w,h,s)

		@frontier = []

		# 
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		#
		@delay = d
		@animate = a
		if not @animate
			carve_passages
		end
	end

	attr_reader :animate, :delay

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Method only needs to be overridden if we are animating.
	#
	# If we are drawing the maze statically, defer to the superclass.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def draw
		# 
		# Clear the screen.
		#
		print "\e[2J"

		if not @animate

			# 
			# Move to upper left and defer to superclass.			
			#
			print "\e[H"
			super()

		else
			#
			# If we are animating, clear the screen and start carving!
			#
			carve_passages
		end
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Invoked to render animated version of the ASCII maze
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++
	def display
		#
		# Draw the "top row" of the maze
		#
		print "\e[H"
		puts " " + "_" * (@width * 2 - 1)	

		# 
		# Step through the grid cells of the maze
		#	
		@grid.each_with_index do |row,y|
			print "|"
			row.each_with_index do |cell,x|
				
				# 
				# Color the cell if its frontier
				#
				print "\e[41m" if cell == @@FRONTIER
				if empty?(cell) && y+1 < @height && empty?(@grid[y+1][x])
					print " "
				else
					print((cell & @@S != 0) ? " " : "_")
				end
				print "\e[m" if cell == @@FRONTIER

				#
				# Draw the "grid" of the maze
				#
				if empty?(cell) && x+1 < @width && empty?(row[x+1])
					print((y+1 < @height && (empty?(@grid[y+1][x]) || empty?(@grid[y+1][x+1]))) ? " " : "_")
				elsif cell & @@E != 0
					print(((cell | row[x+1]) & @@S != 0) ? " " : "_")
				else
					print "|"
				end
			end
			puts
		end
	end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Carve the passages in the maze using the Prim algorithm	
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def carve_passages

		# 
		# Select random pointin the grid to begin carving
		#
		mark( rand(@width) , rand(@height) )

		# 
		# Marking an empty matrix creates a frontier. 
		# Keep going until there is no frontier.
		#
		until @frontier.empty?

			# 
			# Randomly select a frontier point, and 
			# randomly selected one of the neighboring
			# points to that frontier point.
			#
			x, y = @frontier.delete_at( rand(@frontier.length) )
			n = neighbors(x, y)
			nx, ny = n[ rand(n.length) ]

			#
			# "Knock down" the wall between the selected
			# frontier point and its neighbor.
			#
			dir = direction(x, y, nx, ny)
			@grid[y][x] |= dir
			@grid[ny][nx] |= @@OPPOSITE[dir]

			# 
			# Recursively mark the newly selected point.
			#
			mark(x, y)

			#
			# If we are animating, display the maze
			#		
			if @animate
				display
				sleep @delay 
			end
		end

		#
		# If we are animating, display the maze (one last time)
		#
		if @animate
			display

			# 
			# Output maze metadata.
			#
			puts "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
		end
	end

	# ++++++++++++++++++++++++++++++++++++++++++
	# Add the grid point (x,y) to the frontier 
	# so long as its within bounds and empty.
	# ++++++++++++++++++++++++++++++++++++++++++
	def add_to_frontier(x, y)
		if x >= 0 && y >= 0 && y < @height && x < @width && @grid[y][x] == 0
			@grid[y][x] |= @@FRONTIER
			@frontier << [x,y]
		end
	end

	# ++++++++++++++++++++++++++++++++++++++++++++
	# Add the grind point (x,y) to the maze, and
	# add its neighboring points to the frontier.
	# ++++++++++++++++++++++++++++++++++++++++++++
	def mark(x,y)
		@grid[y][x] |= @@IN

		add_to_frontier( x-1, y )	
		add_to_frontier( x+1, y )
		add_to_frontier( x, y-1 )
		add_to_frontier( x, y+1 )
	end

	# +++++++++++++++++++++++++++++++++++++++++++++
	# Find the points which are inbounds and which 
	# have not yet been added to the matrix.
	# +++++++++++++++++++++++++++++++++++++++++++++
	def neighbors(x, y)
		n = []
		
		n << [x-1, y] if x > 0 && @grid[y][x-1] & @@IN != 0
		n << [x+1, y] if x+1 < @grid[y].length && @grid[y][x+1] & @@IN != 0
		n << [x, y-1] if y > 0 && @grid[y-1][x] & @@IN != 0
		n << [x, y+1] if y+1 < @grid.length && @grid[y+1][x] & @@IN != 0
	
		n
	end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Decide the direction we are moving in.
	#
	# Answer will be one of the class variables N, S, E or W.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def direction(fx, fy, tx, ty)
		return @@E if fx < tx 
		return @@W if fx > tx
		return @@S if fy < ty
		return @@N if fy > ty
	end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++
	# If the cell is empty (i.e., 0) or has been selected 
	# as a "frontier" point, we treat it as being empty.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++
	def empty?(cell)
		cell == 0 || cell == @@FRONTIER
	end
end

# ============================
# Command line code goes here
# ============================
OPTIONS  = {
	:w => DEFAULT_WIDTH,
	:h => DEFAULT_HEIGHT,
	:s => DEFAULT_SEED,
	:a => DEFAULT_ANIMATE,
	:d => DEFAULT_DELAY
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator ""
		o.on("-w","--width=[value]", Integer, "Width of maze (default: " + DEFAULT_WIDTH.to_s + ")") 		{ |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "Height of maze (default: " + DEFAULT_HEIGHT.to_s + ")")		{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "User-defined seed will model deterministic behavior (default: " + DEFAULT_SEED.to_s + ")")	{ |OPTIONS[:s]| }
		o.on("-a","--[no-]animated", true.class, "Animate rendering (default: " + DEFAULT_ANIMATE.to_s + ")")		{ |OPTIONS[:a]| }
		o.on("-d","--delay=[value]", Float, "Animation delay (default: " + DEFAULT_DELAY.to_s + ")") { |OPTIONS[:d]| }
		o.separator ""
		o.parse!

		# sanitize the input from the command line
		good = true
		if OPTIONS[:w] == "" or OPTIONS[:w] == nil 
			good = false
		elsif OPTIONS[:h] == "" or OPTIONS[:h] == nil 
			good = false
		elsif OPTIONS[:s] == "" or OPTIONS[:s] == nil
			good = false
		elsif OPTIONS[:d] == "" or OPTIONS[:d] == nil
			good = false
  		end

		if good
			# build and draw a new maze
			Prim.new( w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d] ).draw
		else
			puts o
		end
	end
end
