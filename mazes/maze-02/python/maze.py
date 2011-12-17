#!/usr/bin/python

import random
import sys
import time
from optparse import OptionParser

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10 
DEFAULT_SEED = None   # using None will seed PRNG with current system time
DEFAULT_ANIMATE = False
DEFAULT_DELAY = 0.04

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
        buffer.append(self.metadata())

        print "\r\n".join(buffer)

    def metadata(self,):
        """Output generic maze metadata."""
        return " ".join([sys.argv[0],str(self.width),str(self.height),str(self.seed)])

class BinaryTree(Maze):
    """Class BinaryTree implements a simple binary tree algorithm to draw simple ASCII mazes.

1. Start in the upper-left cell of the maze.
2. Randomly carve either toward the east or south.

And that's it!

The algorithm is fast and simple, but has two significant drawbacks: (a) two of the four
sides (in this case, the north and west) will be spanned by a single corridor; and (b)
the maze will exhibit a strong diagonal bias (in this case, north-west to south-east).
"""

    def __init__(self,w=DEFAULT_WIDTH,h=DEFAULT_HEIGHT,s=DEFAULT_SEED,a=DEFAULT_ANIMATE,d=DEFAULT_DELAY):
        """Initialize a new 2D maze with the given width and height.

Default seed value will give "random" behavior.
User-supplied seed value will give "deterministic" behavior.
"""
        #
        # Invoke super-constructor.
        #
        super(BinaryTree,self).__init__(w,h,s)

        #
        # Only prepare the maze beforehand if we are doing "static" (i.e., animate=false) drawing
        #
        self.delay = d
        self.animate = a
        if not self.animate:
            BinaryTree.carve_passages(self)

    def carve_passages(self,):
        """Walk down the maze, cell-by-cell, carving a maze using the binary tree algorithm.

Because we walk down the maze, cell-by-cell, in a linear fashion, this
algorithm is amenable to animation. Animated version is implemented in the 
overridden draw() method below."""

        for y in range(self.height):
            for x in range(self.width):
                if self.animate:
                    self.display(x,y)
                    time.sleep(self.delay)

                dirs = [] 
                if y > 0:
                    dirs.append(Maze.N)
                if x > 0:
                    dirs.append(Maze.W)

                if len(dirs) > 0:
                    dir = dirs[random.randint(0,len(dirs)-1)]
                    if dir:
                        dx,dy = x + Maze.DX[dir], y + Maze.DY[dir]
                        self.grid[y][x] |= dir
                        self.grid[dy][dx] |= Maze.OPPOSITE[dir]

        if self.animate:
            self.display(-1,-1)

    def draw(self,update=False):
        """Method only needs to be overridden if we are animated.

If we are drawing the maze statically, defer to the superclass."""

        if update or not self.animate:
            sys.stdout.write("\x1b[H")
            if not self.animate:
                sys.stdout.write("\x1b[2J")
            Maze.draw(self,)
        else:
            sys.stdout.write("\x1b[2J")
            BinaryTree.carve_passages(self)

    def display(self,i,j):
        """Display needs the (x,y) coordinate of where it is presently rendering, in 
order to color the "current cursor" cell a different color (in this case, 
red). We've already used the symbols "x" and "y" in a previous implementation
of this algorithm, so we'll name them "i" and "j" in the method signature instead.
"""
        sys.stdout.write("\x1b[H")
        buffer = []; out = " "
        for c in range(2 * self.width - 1):
            out += "_"
        buffer.append(out)

        # 
        # Step through the cells of the maze
        #
        for y in range(self.height):
            out = "|"
            for x in range(self.width):
                #
                # Color gray if empty, red if "current" cursor
                #
                if self.grid[y][x] == 0:
                    out += "\x1b[47m"
                if x == i and y == j:
                    out += "\x1b[41m"

                # Render "bottom" using "S" switch
                out += " " if ((self.grid[y][x] & Maze.S) != 0) else "_"

                # Render "side" using "E" switch
                if ( self.grid[y][x] & Maze.E ) != 0:
                    out += " " if (((self.grid[y][x] | self.grid[y][x+1]) & Maze.S) != 0) else "_"
                else:
                    out += "|"

                #
                # Stop coloring
                #
                if self.grid[y][x] == 0 or ( x == i and y == j ):
                    out += "\x1b[m"

            buffer.append(out)

        # 
        # Output metadata
        #
        buffer.append(self.metadata())
        buffer.append("")
        sys.stdout.write("\r\n".join(buffer))

        
    def metadata(self,):
        """Override metadata to inform what type of maze we are carving."""
        return Maze.metadata(self,) + " [BinaryTree]"

# 
# Parse the command line arguments
#
parser = OptionParser()
parser.set_conflict_handler("resolve")
parser.add_option("-w","--width",dest="width",help="width of maze",metavar="<maze-width>")
parser.add_option("-h","--height",dest="height",help="height of maze",metavar="<maze-height>") 
parser.add_option("-s","--seed",dest="seed",help="seed for PRNG generator",metavar="<prng-seed>")
parser.add_option("-a","--animated",action="store_true",dest="animated",help="animate rendering?",metavar="<animated?>")
parser.add_option("-d","--delay",dest="delay",help="animation delay",metavar="<animation-delay>")
(options, args) = parser.parse_args()

#
# Set the arguments we will use
#
w = DEFAULT_WIDTH if options.width is None else int(options.width)
h = DEFAULT_HEIGHT if options.height is None else int(options.height)
s = DEFAULT_SEED if options.seed is None else int(options.seed)
a = True if options.animated else False
d = DEFAULT_DELAY if options.delay is None else float(options.delay)

#
# Build and draw a new maze
#
m = BinaryTree(w,h,s,a,d)
m.draw()

