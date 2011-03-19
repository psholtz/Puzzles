#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false

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
		puts "#{$0} #{@width} #{@height} #{@seed}"
	end

	def inspect
		@height.times do |y|
			print "|"
			@width.times do |x|
				print @grid[y][x]
			end
		end
	end
end

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
	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE )
		# 
		# Invoke super-constructor
		#
		super(w,h,s)

		@frontier = []

		# 
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		#
		@animate = a
		if not @animate
			carve_passages
		end
	end

	attr_reader :animate

	def draw
		if not @animate
			super()
		end
	end
	
	def carve_passages
		mark( rand(@width) , rand(@height) )
		until @frontier.empty?
			x, y = @frontier.delete_at( rand(@frontier.length) )
			n = neighbors(x, y)
			nx, ny = n[ rand(n.length) ]

			dir = direction(x, y, nx, ny)
			@grid[y][x] |= dir
			@grid[ny][nx] |= @@OPPOSITE[dir]

			mark(x, y)
		end
	end

	def add_to_frontier(x, y)
		#print "x: " + x.to_s + ", y: " + y.to_s + ", h: " + @height.to_s + ", w: " + @width.to_s + ", grid: " + @grid[y][x].to_s
		#print ", (8,8): " + @grid[8][8].to_s
		#puts
		if x >= 0 && y >= 0 && y < @height && x < @width && @grid[y][x] == 0
			@grid[y][x] |= @@FRONTIER
			@frontier << [x,y]
		end
	end

	def mark(x,y)
		@grid[y][x] |= @@IN

		add_to_frontier( x-1, y )	
		add_to_frontier( x+1, y )
		add_to_frontier( x, y-1 )
		add_to_frontier( x, y+1 )
	end

	def neighbors(x, y)
		n = []
		
		n << [x-1, y] if x > 0 && @grid[y][x-1] & @@IN != 0
		n << [x+1, y] if x+1 < @grid[y].length && @grid[y][x+1] & @@IN != 0
		n << [x, y-1] if y > 0 && @grid[y-1][x] & @@IN != 0
		n << [x, y+1] if y+1 < @grid.length && @grid[y+1][x] & @@IN != 0
	
		n
	end

	def direction(fx, fy, tx, ty)
		return @@E if fx < tx 
		return @@W if fx > tx
		return @@S if fy < ty
		return @@N if fy > ty
	end

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
	:a => DEFAULT_ANIMATE
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator ""
		o.on("-w","--width=[value]", Integer, "Width of maze (default: " + DEFAULT_WIDTH.to_s + ")") 		{ |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "Height of maze (default: " + DEFAULT_HEIGHT.to_s + ")")		{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "User-defined seed will model deterministic behavior (default: " + DEFAULT_SEED.to_s + ")")	{ |OPTIONS[:s]| }
		o.on("-a","--[no-]animated", true.class, "Animate rendering (default: " + DEFAULT_ANIMATE.to_s + ")")		{ |OPTIONS[:a]| }
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
			# build and draw a new binary tree maze
			Prim.new( w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a] ).draw
		else
			puts o
		end
	end
end
