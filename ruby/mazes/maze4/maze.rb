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
	@@DX = { @@E => 1, @@W => -1, @@N => 0, @@S => 0 }
	@@DY = { @@E => 0, @@W => 0, @@N => -1, @@S => 1 }
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

class Kruskal < Maze

	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE, d=DEFAULT_DELAY )
		# 
		# Invoke super-constructor
		#
		super(w,h,s)
		
		#
		# Initialize the sets to the same dimension as the maze.
		# We use Tree objects to represent the sets to be joined.
		#
		@sets = Array.new(height) { Array.new(width) { Tree.new } }
		
		#
		# Build the collection of edges and randomize
		#
		@edges = []
		@height.times do |y|
			@width.times do |x|
				@edges << [x, y, @@N] if y > 0
				@edges << [x, y, @@W] if x > 0
			end
		end
		@edges = @edges.sort_by{rand}
		
		# 
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		#
		@animate = a
		@delay = d
		if not @animate
			carve_passages
		end
	end

	attr_reader :animate
	
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Method only needs to be overridden if we are animating.
	#
	# If we are drawing the maze statically, defer to the superclass.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def draw
		print "\e[2J"
		if not @animate
			print "\e[H"
			super()
		else
			carve_passages
		end
	end
	
	def display
		print "\e[H"
		puts " " + "_" * ( @width * 2 - 1)
		@grid.each_with_index do |row,y|
			print "|"
				row.each_with_index do |cell,x|
					print "\e[47m" if cell == 0
					print((cell & @@S != 0) ? " " : "_")
					
					if cell & @@E != 0
						print(((cell | row[x+1]) & @@S != 0) ? " ": "_")
					else
						print "|"
					end
					
					print "\e[m" if cell == 0
				end
			puts
		end
	end
	
	def carve_passages
		until @edges.empty?
			x, y, direction = @edges.pop
			dx, dy = x + @@DX[direction], y + @@DY[direction]
			
			set1, set2 = @sets[y][x], @sets[dy][dx]
			
			unless set1.connected?(set2)
				if @animate
					display
					sleep(@delay)
				end
				
				set1.connect(set2)
				@grid[y][x] |= direction
				@grid[dy][dx] |= @@OPPOSITE[direction] 
			end
		end
		
		if @animate
			display
			
			#
			# Output maze metadata.
			#
			puts "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
		end
	end
end

class Tree
	def initialize
		@parent = nil
	end

	attr_accessor :parent

	def root
		@parent ? @parent.root : self
	end

	def connected?(tree)
		root == tree.root
	end

	def connect(tree)
		tree.root.parent = self
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
		o.on("-d","--delay=[value]", Float, "Animation delay (default: " + DEFAULT_DELAY.to_s + ")")	{ |OPTIONS[:d]| } 
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
			Kruskal.new( w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d] ).draw
		else
			puts o
		end
	end
end

