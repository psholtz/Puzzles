#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.02
DEFAULT_MODE = "random"


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
		puts "#{$0} #{@width} #{@height} #{@seed} #{@delay} #{@mode}"
	end
end

class GrowingTree < Maze

	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE, d=DEFAULT_DELAY, m=DEFAULT_MODE )
		#
		# Invoke super-constructor
		#
		super(w,h,s)
		
		#
		# Configure the script
		#
		@mode = m.downcase
		@script = Script.new(@mode)
		
		#
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		#
		@delay = d
		@animate = a
		if not @animate
			carve_passages
		end
	end
	
	attr_reader :delay, :animate, :mode, :script
	
	def draw
		print "\e[2J"
		print "\e[H"
		super()
	end
	
	def display
	
	end
	
	def carve_passages
		# configure variables
		cells = []
		
		x, y = rand(width), rand(height)
		cells << [x, y]
		#until cells.empty?
		#	index = script.next_index(cells.length)
			
			
		#end
	end
end

class Script
	def initialize(arg)
		#
		# User can supply a list of commands, separated by ";", on the command line
		# Here we split these commands by parsing on the ";" character. 
		#
		@commands = arg.split(/;/).map { |cmd| parse_command(cmd) }
		
		#
		# Index into the above array.
		# Initialize it to first element.
		#
		@current = 0
	end
	
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Each command may consist of a comma-delimited list of subcommands.
	# This method parses out those subcommands.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	def parse_command(cmd)
	
		total_weight = 0
		
		# 
		# Parse out the subcommands, in comma-delimited list.
		# 
		parts = cmd.split(/,/).map do |element|
		
			#
			# Each subcommand may consist of a "command:weight" pair.
			# If there is no assigned value, assign the weight to be 100
			# 
		    name, weight = element.split(/:/)
		    weight ||= 100
		    abort "Commands must be: random, newest, middle or oldest (was #{name.inspect})" unless %w(random r newest n middle m oldest o).include?(name)
		    
		    #
		    # Update total weight.
		    #
		    total_weight += weight.to_i
		    
		    #
		    # Add these symbols to each element of "parts"
		    #
			{ :name => name.to_sym, :weight => weight }
		end
		
		#
		# Add these symbols to "cmd" itself
		#
		{ :total => total_weight, :parts => parts }
	end
	
	def next_index(ceil)
		# 
		# Get the next command, and advance the pointer.
		#
		command = @commands[@current]
		@current = (@current + 1) % @commands.length
	end
end

# ============================
# Command line code goes here
# ============================
OPTIONS = {
	:w => DEFAULT_WIDTH,
	:h => DEFAULT_HEIGHT,
	:s => DEFAULT_SEED,
	:a => DEFAULT_ANIMATE,
	:d => DEFAULT_DELAY,
	:m => DEFAULT_MODE
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator ""
		o.on("-w","--width=[value]", Integer, "Width of maze (default: " + DEFAULT_WIDTH.to_s + ")") { |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "Height of maze (default: " + DEFAULT_HEIGHT.to_s + ")") { |OPTIONS[:h]| }
		o.on("-a","--[no-]animated", true.class, "Animate rendering (default: " + DEFAULT_ANIMATE.to_s + ")") { |OPTIONS[:a]| }
		o.on("-d","--delay=[value]", Float, "Animation delay (default: " + DEFAULT_DELAY.to_s + ")") { |OPTIONS[:d]| }
		o.on("-m","--mode=[value]", String, "Mode (default: )") { |OPTIONS[:m]| }
		o.on("-s","--seed=[value]", Integer, "User-defined seed will model deterministic behavior (default: " + DEFAULT_SEED.to_s + ")") { |OPTIONS[:s]| }
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
		elsif OPTIONS[:m] == "" or OPTIONS[:m] == nil
			good = false
		end

		if good
			# build and draw a new binary tree maze
			GrowingTree.new( w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d], m=OPTIONS[:m] )#.draw
		else
			puts o
		end
	end
end