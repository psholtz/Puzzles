#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.04

# ====================================================================
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
		# Output maze metadata.
		#
		puts metadata
	end

	# ++++++++++++++++++++++++++++++ 
	# Output generic maze metadata.
	# ++++++++++++++++++++++++++++++
	def metadata
	    "#{$0} #{@width} #{@height} #{@seed}" 
	end
end

# ========================================================================================
# Class BinaryTree implements a simple binary tree algorithm to draw simple ASCII mazes.
# 
# 1. Start in the upper-left cell of the maze.
# 2. Randomly carve either towards the east or south.
#
# And that's it!
#
# The algorithm is fast and simple, but has two significant drawbacks: (a) two of the four
# sides (in this case, the north and west) will be spanned by a single corridor; and (b) 
# the maze will exhibit a strong diagonal bias (in this case, north-west to south-east).
# =========================================================================================
class BinaryTree < Maze

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

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Walk down the maze, cell-by-cell, carving a maze using the binary tree algorithm.
	#
	# Because we walk down the maze, cell-by-cell, in a linear fashion, this 
	# algorithm is amenable to animation. Animated version is implemented in the 
	# overridden draw() method below
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def carve_passages
		@height.times do |y|
			@width.times do |x|
				# 
				# Render updates of the maze on a "cell-by-cell" basis
				#
				if @animate
					display(x,y)
					sleep @delay
				end

				dirs = []
				dirs << @@N if y > 0
				dirs << @@W if x > 0

				if ( dir = dirs[rand(dirs.length)] ) 
					dx,dy = x + @@DX[dir], y + @@DY[dir]
					@grid[y][x] |= dir
					@grid[dy][dx] |= @@OPPOSITE[dir]
				end	
			end
		end

		#
		# Make one final call to "update" to display last cell
		#
		if @animate
			display(-1,-1)
		end
	end

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Method only needs to be overridden if we are animated.
	#
	# If we are drawing the maze statically, defer to the superclass.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def draw(update=false)
		if update or not @animate
			print "\e[H"
			if not @animate; print "\e[2J"; end
			super()
		else
			print "\e[2J"
			carve_passages
		end
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Display needs the (x,y) coordinates of where it is presently rendering, in 
	# order to color the "current cursor" cell a different color (in this case, 
	# red). We've already used the symbols "x" and "y" in a previous implementation
	# of this algorithm, so we'll name them "i" and "j" in the method signature instead.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def display(i,j)
	    #
	    # Draw the "top" line
	    #
	    print "\e[H"
	    puts " " + "_" * ( 2 * @width - 1)
	    
	    #
	    # Step through the maze, one cell at a time
	    #
	    @height.times do |y|
	        print "|"
	        @width.times do |x|
		    # 
		    # Color gray if empty, red if "current" cursor
		    #
		    if @grid[y][x] == 0
		        print "\e[47m"
		    end
		    if x == i and y == j
		        print "\e[41m"
		    end

		    # Render "bottom" using "S" switch
		    print( (@grid[y][x] & @@S != 0) ? " " : "_")

		    # Render "side" using "E" switch
		    if @grid[y][x] & @@E != 0
  		        print( ( (@grid[y][x] | @grid[y][x+1]) & @@S != 0 ) ? " " : "_" )
		    else 
		        print "|"
		    end

		    #
		    # Stop coloring
		    #
		    if @grid[y][x] or ( x == i and y == j ) 
		        print "\e[m"
		    end
	        end
		puts
	    end

	    #
	    # Output metadata
	    #
	    puts metadata
	end

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Override metadata to inform what type of maze we are carving
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	def metadata
	    super() + " [BinaryTree]"
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
			# build and draw a new binary tree maze
			BinaryTree.new(w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d]).draw
		else
			puts o
		end
	end
end
