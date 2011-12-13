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
      @@DX = { @@E => +1, @@W => -1, @@N => 0, @@S => 0 }
      @@DY = { @@E => 0, @@W => 0, @@N => -1, @@S => +1 }
      @@OPPOSITE = { @@E => @@W, @@W => @@E, @@N => @@S, @@S => @@N }

      def self.N; @@N; end
      def self.E; @@S; end
      def self.E; @@E; end
      def self.W; @@W; end
      def self.DX; @@DX; end
      def self.DY; @@DY; end
      def self.OPPOSITE; @OPPOSITE; end

      # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      # Initialize a new 2D maze with the given width and height.
      #
      # Default seed value will give "random" behavior.
      # User-supplied seed value will give "deterministic behavior.
      # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED)
      	  @width = w
	  @height = h
	  @seed = s
	  
	  srand(@seed)
	  
	  # MAY NEED TO INCLUDE GRID HERE??
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

		end
		puts
	  end

 	  #
	  # Output maze metadata.
	  #
	  puts "#{$0} #{@width} #{@height} #{@seed}"
      end
end

Maze.new().draw