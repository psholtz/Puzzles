#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)

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
		o.on("-w","--width=[value]", Integer, "(optional)") 		{ |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "(optional)")		{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "(optional)")		{ |OPTIONS[:s]| }
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
			Maze.new(w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s]).draw
		else
			puts o
		end
	end
end
