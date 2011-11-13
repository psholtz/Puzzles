#!/usr/bin/python

import random
import sys
from optparse import OptionParser

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10 
DEFAULT_SEED = None   # using None will seed PRNG with current system time

class Maze(object):
    """Class Maze defines basic behavior to which a maze should conform.
It provides basic initialization/construction for the maze class, 
and provides a method for drawing ASCII mazes.

Specific "maze-carving" techniques are implemented in subclasses."""

    #
    # Configure class variables
    #
    N,S,E,W = 1,2,4,8
    DX = { E:+1, W:-1, N:0, S:0 }
    DY = { E:0, W:0, N:-1, S:+1 }
    OPPOSITE = { E:W, W:E, N:S, S:N } 

    def __init__(self,w=DEFAULT_WIDTH,h=DEFAULT_HEIGHT,s=DEFAULT_SEED):
        """Initialize a new 2D maze with the given width and height.

Default seed will give 'random' behavior.
User-supplied seed will give deterministic behavior."""

        # initialize the instance variables
        self.width = DEFAULT_WIDTH if w is None else w
        self.height = DEFAULT_HEIGHT if h is None else h 
        self.seed = DEFAULT_SEED if s is None else s 

        # seed the PRNG
        random.seed(self.seed)

        # build the grid to hold the maze
        self.grid = [[0 for col in range(self.width)] for row in range(self.height)]

    def draw(self,):
        """Draw the grid, starting in the upper-left hand corner."""

        #
        # Draw the top line
        #
        buffer = []; out = " "
        for i in range(2*self.width - 1):
            out += "_" 
        buffer.append(out)

        #
        # Draw each of the rows.
        #
        for j in range(self.height):
            out = "|"
            for i in range(self.width):
                # draw the "bottom" using S switch
                out += " " if ((self.grid[j][i] & Maze.S) != 0) else "_"

                # draw the "side" using E switch
                if (self.grid[j][i] & Maze.E) != 0:
                    out += " " if (((self.grid[j][i] | self.grid[j][i+1]) & Maze.S) != 0) else "_"
                else:
                    out += "|"
     
            buffer.append(out)

        # 
        # Output maze metadata.
        #
        out = " ".join([sys.argv[0],str(self.width),str(self.height),str(self.seed)])
        buffer.append(out)

        print "\r\n".join(buffer)


class BackTracker(Maze):
    """Class BackTracker implements a simple recursive back-tracking algorithm 
to draw ASCII mazes. The algorithm works as a "depth-first" search
of the "tree" or "graph" representing the maze.

A possible optimization might be to implement a "breadth-first" search.
"""

    def __init__(self,w=DEFAULT_WIDTH,h=DEFAULT_HEIGHT,s=DEFAULT_SEED):
        """Initialize a new 2D maze with the given width and height.

Default seed value will give "random" behavior.
User-supplied seed value will give "deterministic" behavior.
"""
        #
        # Invoke super-constructor.
        #
        super(BackTracker,self).__init__(w,h,s)

        #
        # Carve the grid.
        #
        self.carve_passage_from(0,0)

    def carve_passage_from(self,x,y):
        """Recursively carve passages through the maze, starting at (x,y).

Algorithm halts when all "cells" in the maze have been visited."""

        # 
        # Randomly shuffle the directions.
        #
        directions = [Maze.N, Maze.S, Maze.E, Maze.W]
        random.shuffle(directions)    

        #
        # Step through the maze, and recursively invoke the procedure.
        #
        for direction in directions:
            dx,dy = x + Maze.DX[direction], y + Maze.DY[direction]
            if dy >= 0 and dy < self.height and dx >= 0 and dx < self.width and self.grid[dy][dx] == 0:
                self.grid[y][x] |= direction
                self.grid[dy][dx] |= Maze.OPPOSITE[direction]
                self.carve_passage_from(dx,dy)


# 
# Parse the command line arguments
#
parser = OptionParser()
parser.set_conflict_handler("resolve")
parser.add_option("-w","--width",dest="width",help="width of maze",metavar="<maze-width>")
parser.add_option("-h","--height",dest="height",help="height of maze",metavar="<maze-height>") 
parser.add_option("-s","--seed",dest="seed",help="seed for PRNG generator",metavar="<prng-seed>")
(options, args) = parser.parse_args()

#
# Set the arguments we will use
#
w = DEFAULT_WIDTH if options.width is None else int(options.width)
h = DEFAULT_HEIGHT if options.height is None else int(options.height)
s = DEFAULT_SEED if options.seed is None else int(options.seed)

#
# Build and draw a new maze
#
m = BackTracker(w,h,s)
m.draw()

