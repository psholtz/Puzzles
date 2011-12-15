#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.02

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
	
	attr_reader :width, :height, :seed

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
				print( (@grid[y][x] & @@S != 0) ? " " : "_" )
			
				# render "side" using "E" switch	
				if @grid[y][x] & @@E != 0
					print( ( (@grid[y][x] | @grid[y][x+1]) & @@S != 0 ) ? " " : "_" )
				else
					print "|"
				end
			end
			puts
		end

		# 
		# Output metadata
		#
		puts metadata
	end

	# ++++++++++++++++++++++++++++++ 
	# Output generic maze metadata.
	# ++++++++++++++++++++++++++++++ 
	def metadata
	    "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
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
	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE, d=DEFAULT_DELAY )
		#
		# Invoke super-constructor
		#
		super(w,h,s)

		# 
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate=false) drawing
		#
		@delay = d
		@animate = a
		if not @animate
		      carve_passage_from(0,0)
		end
	end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Recursively carve passages through the maze, starting at (x,y).
	#
	# Algorithm halts when all "cells" in the maze have been visited.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def carve_passage_from(x,y)
		directions = [@@N,@@S,@@E,@@W].sort_by{rand}
		directions.each do |direction|
			#
			# Render updates of the maze on a "cell-by-cell" basis
			#
			if @animate
			      display(x,y)
			      sleep @delay
			end

			dx,dy = x + @@DX[direction], y + @@DY[direction]
			if dy.between?(0,@grid.length-1) && dx.between?(0,@grid[dy].length-1) && @grid[dy][dx] == 0
				@grid[y][x] |= direction			# "open" the wall from current cell;
				@grid[dy][dx] |= @@OPPOSITE[direction]		# "open" the wall from adjacent cell;
				carve_passage_from(dx,dy)
			end
		end

		# 
		# Make one final call to "update" to display last cell.
		# Set the coords to (-1,-1) so the cell is left "blank" with no cursor.
		#
		if @animate
		      display(-1,-1)
		end
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Display needs the (x,y) coordinates of where it is presently rendering, in 
	# order to color the "current cursor" cell a different color (in this case, 
	# red). We've already used the symbols "x" and "y" in a previous implementation
	# of this algorithm, so we'll name them "i" and "j" in the method signature instead.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def display(i,j)
 	      print "\e[H"
	      puts " " + "_" * (@width * 2 - 1)
	      
	      @grid.each_with_index do |row,y|
	            print "|"
		    row.each_with_index do |cell,x|
		          # 
			  # Color gray if empty, red if "current" cursor
			  #
			  if cell == 0
			        print "\e[47m" 
			  elsif x == i and y == j
 			        print "\e[41m"
			  end

			  # render "bottom" using "S" switch
			  print( (@grid[y][x] & @@S != 0) ? " " : "_" )
			  
			  # render "side" using "E" switch
			  if @grid[y][x] & @@E != 0
			        print( ( (@grid[y][x] | @grid[y][x+1]) & @@S != 0 ) ? " " : "_" )
			  else
			        print "|"
			  end

			  # 
			  # Stop coloring
			  #
			  if cell == 0 or ( x == i and y == j )
			        print "\e[m" 
			  end
		    end
		    puts
	      end
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Method only needs to be overridden if we are animating.
	# 
	# If we are drawing the maze statically, defer to the superclass.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	def draw

	    # 
	    # Clear the screen.
	    #
	    print "\e[2J"
	    if not @animate
	       
	        # 
		# Move to upper left and defer to superclass
		#		
	        print "\e[H"
		super()
	    else
		#
		# If we are animating, clear the screen and start carving!
		#
		carve_passage_from(0,0)

		#
		# Output maze metadata
		#
		puts metadata
	    end
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Override metadata to inform what type of maze we are carving
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def metadata
	    "#{$0} #{@width} #{@height} #{@seed} #{@delay} [BackTracker]"
	end

	protected :carve_passage_from
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
		o.on("-h","--height=[value]", Integer, "Height of maze (default: " + DEFAULT_HEIGHT.to_s+ ")")		{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "User-defined seed will model deterministic behavior (default: " + DEFAULT_SEED.to_s + ")")	{ |OPTIONS[:s]| }
		o.on("-a","--[no-]animated", true.class, "Animate rendering (default: " + DEFAULT_ANIMATE.to_s + ")") 	{ |OPTIONS[:a]| }
		o.on("-d","--delay=[value]", Float, "Animation delay (default: " + DEFAULT_DELAY.to_s + ")")   	 	{ |OPTIONS[:d]| }
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
			# build and draw a new back-tracking maze
			BackTracker.new(w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d]).draw
		else
			puts o
		end
	end
end