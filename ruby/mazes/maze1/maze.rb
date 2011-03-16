#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)

# ===================================================================
# Class Maze defines basic behavior to which a maze should conform.
# It provides basic initialization/construction for the maze class, 
# and provides a method for drawing ASCII mazes. 
#
# Specific "maze-carving" techniques are implemented in subclasses.
# ====================================================================
class Maze
	# +++++++++++++++++++++++++++
	# Configure class variables.
	# +++++++++++++++++++++++++++
	@@N, @@S, @@E, @@W = 1, 2, 4, 8 
	@@DX = { @@E => 1, @@W => -1, @@N => 0, @@S => 0 }
	@@DY = { @@E => 0, @@W => 0, @@N => -1, @@S => 1 }
	@@OPPOSITE = { @@E => @@W, @@W => @@E, @@N => @@S, @@S => @@N }

	def self.N; @@N; end
	def self.S; @@S; end
	def self.E; @@E; end
	def self.W; @@W; end
	def self.DX; @@DX; end
	def self.DY; @@DY; end
	def self.OPPOSITE; @@OPPOSITE; end
	
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Initialize a new 2D maze with the given width and height.
	#
	# Default seed value will give "random" behavior.
	# User-supplied seed value will give "deterministic behavior.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED )
		@width = w
		@height = h
		@seed = s

		srand(@seed)	

		@grid = Array.new(h) { Array.new(w,0) }
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Draw the grid, starting in the upper-left hand corner.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def draw
		#
		# Draw the "top" line.
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
		puts "#{$0} #{@width} #{@height}  #{@seed}"
	end
end

# =========================================================================
# Class BackTracker implements a simple recursive back-tracking algorithm
# to draw ASCII mazes. The algorithms works as a "depth-first" search
# of the "tree" or "graph" representing the maze.
# 
# A possible optimization might be to implement a "breadth-first" search.
# =========================================================================
class BackTracker < Maze

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Initialize a new 2D maze with the given width and height.
	#
	# Default seed value will give "random" behavior.
	# User-supplied seed value will give "deterministic behavior.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED )
		#
		# Invoke super-constructor
		#
		super

		#
		# Carve the grid
		#
		create_passage_from(0,0)
	end

	def create_passage_from(x,y)
		directions = [@@N,@@S,@@E,@@W].sort_by{rand}
		directions.each do |direction|
			dx,dy = x + @@DX[direction], y + @@DY[direction]
			if dy.between?(0,@grid.length-1) && dx.between?(0,@grid[dy].length-1) && @grid[dy][dx] == 0
				@grid[y][x] |= direction			# "open" the wall from current cell;
				@grid[dy][dx] |= @@OPPOSITE[direction]		# "open" the wall from adjacent cell;
				create_passage_from(dx,dy)
			end
		end
	end

	protected :create_passage_from
end

# ============================
# Command line code goes here
# ============================
OPTIONS  = {
	:w => DEFAULT_WIDTH,
	:h => DEFAULT_HEIGHT,
	:s => DEFAULT_SEED
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator ""
		o.on("-w","--width=[value]", Integer, "Width") 		{ |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "Height")	{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "Seed")		{ |OPTIONS[:s]| }
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
  		end

		if good
			# build and draw a new back-tracking maze
			BackTracker.new(w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s]).draw
		else
			puts o
		end
	end
end
