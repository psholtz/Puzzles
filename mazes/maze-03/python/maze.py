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
        """Output maze metadata."""
        return " ".join([sys.argv[0],str(self.width),str(self.height),str(self.seed)])

class Prim(Maze):
    """Use randomized variant of Prim's algorithm to generate a maze.

The algorithm is implemented as follows:

(1) Randomly select a grid point, and add it to the maze.
(2) Update the set of "frontier" cells (i.e, cells not in the maze, but which border the maze).
(3) Randomly select a "frontier" cell, and add it to the maze.
(4) "Knock down" the wall between these two cells.
(5) Go back to Step 2, and repeat until there are no more frontier cells.
"""

    #
    # Configure class variables.
    #
    IN = 0x10
    FRONTIER = 0x20
 
    def __init__(self,w=DEFAULT_WIDTH,h=DEFAULT_HEIGHT,s=DEFAULT_SEED,a=DEFAULT_ANIMATE,d=DEFAULT_DELAY):
        """Initialize a new 2D maze with the given width and height.

Default seed value will give "random" behavior.
User-supplied seed value will give "deterministic" behavior.
"""
        #
        # Invoke super-constructor.
        #
        super(Prim,self).__init__(w,h,s)

        self.frontier = []

        #
        # Only prepare the maze beforehand if we are doing "static" (i.e., animate=false) drawing
        #
        self.delay = d
        self.animate = a
        if not self.animate:
            Prim.carve_passages(self)

    def carve_passages(self,):
        """Carve the passages in the maze using the Prim algorithm."""
 
        # 
        # Select random points the grid to begin carving
        #
        Prim.mark( self, random.randint(0,self.width-1), random.randint(0,self.height-1) )

        # 
        # Marking an empty matrix creates a frontier.
        # Keep going until there is no frontier.
        #
        while len(self.frontier) > 0:
  
            #
            # Randomly select a front point, and 
            # randomly select one of the neighboring
            # points to add to the frontier point.
            #
            t = self.frontier[random.randint(0,len(self.frontier)-1)]
            self.frontier.remove(t)
            (x, y) = t
            n = Prim.neighbors(self, x, y)
            nx, ny = n[ random.randint(0,len(n)-1) ]

            #
            # "Knock down" the wall between the selected
            # frontier point and its neighbor.
            #
            dir = Prim.direction(self, x, y, nx, ny)
            self.grid[y][x] |= dir
            self.grid[ny][nx] |= Maze.OPPOSITE[dir]

            #
            # Recursively mark the newly selected point.
            #
            Prim.mark(self, x, y)

            #
            # If we are animating, display the maze
            # 
            if self.animate:
                Prim.display(self,)
                time.sleep(self.delay)

        #
        # If we are animating, display the maze (one last time)
        #
        if self.animate:
            Prim.display(self,)

            #
            # Output maze metadata.
            #
            print self.metadata()

          
    def display(self,):
        """Invoked the render animated version of the ASCII maze"""
       
        #
        # Draw the "top row" of the maze
        #
        sys.stdout.write("\x1b[H")
        buffer = []; out = " "
        for i in range(2*self.width - 1):
            out += "_"
        buffer.append(out)

        # 
        # Step through the grid cells of the maze
        #
        for y in range(self.height):
            out = "|"
            for x in range(self.width):

                #
                # Color the cell if its frontier
                #
                if self.grid[y][x] == Prim.FRONTIER:
                    out += "\x1b[41m"
  
                if Prim.empty(self,x,y) and y+1 < self.height and Prim.empty(self,x,y+1):
                    out += " "
                else:
                    out += " " if (self.grid[y][x] & Maze.S) != 0 else "_"

                if self.grid[y][x] == Prim.FRONTIER:
                    out += "\x1b[m"

                # Draw the "grid" of the maze
                if Prim.empty(self,x,y) and x+1 < self.width and Prim.empty(self,x+1,y):
                    out += " " if ( y+1 < self.height and ( Prim.empty(self,x,y+1) or Prim.empty(self,x+1,y+1) ) ) else "_"
                elif (self.grid[y][x] & Maze.E) != 0: 
                    out += " " if ( (self.grid[y][x] | self.grid[y][x+1] ) & Maze.S ) != 0 else "_"
                else:
                    out += "|"

            buffer.append(out)

        buffer.append("")
        sys.stdout.write("\r\n".join(buffer))
    

    def draw(self,update=False):
        """Method only needs to be overridden if we are animated.

If we are drawing the maze statically, defer to the superclass."""

        # 
        # Clear the screen.
        #
        sys.stdout.write("\x1b[2J")
   
        if not self.animate:
 
            #
            # Move to upper left and defer to superclass.
            #
            sys.stdout.write("\x1b[H")
            Maze.draw(self)

        else:

            #
            # If we are animating, clear the screen and start carving!
            #`
            Prim.carve_passages(self)

    def mark(self,x,y):
        """Add the grid point (x,y) to the maze, and add its neighboring points to the frontier."""
        self.grid[y][x] |= Prim.IN

        Prim.add_to_frontier( self, x-1, y )
        Prim.add_to_frontier( self, x+1, y )
        Prim.add_to_frontier( self, x, y-1 )
        Prim.add_to_frontier( self, x, y+1 )

    def add_to_frontier(self,x,y):
        """Add the grid point (x,y) to the frontier, so long as it's within bounds and empty."""
        if x >= 0 and y >= 0 and y < self.height and x < self.width and self.grid[y][x] == 0:
            self.grid[y][x] |= Prim.FRONTIER
            self.frontier.append((x,y))
       

    def neighbors(self,x,y): 
        """Find the points which are inbounds and which have not yet been added to the matrix."""

        n = []

        if x > 0 and ( self.grid[y][x-1] & Prim.IN ) != 0:
            n.append((x-1,y)) 
        if x+1 < self.width and ( self.grid[y][x+1] & Prim.IN ) != 0:
            n.append((x+1,y))
        if y > 0 and ( self.grid[y-1][x] & Prim.IN ) != 0:
            n.append((x,y-1))
        if y+1 < self.height and ( self.grid[y+1][x] & Prim.IN ) != 0:
            n.append((x,y+1))

        return n

    def direction(self,fx,fy,tx,ty):
        """Decide the direction we are moving in. 

Answer will be one of the class variables N, S, E or W."""

        if fx < tx: return Maze.E
        if fx > tx: return Maze.W
        if fy < ty: return Maze.S
        if fy > ty: return Maze.N

    def empty(self,x,y):
        """If the cell is empty (i.e., 0) or has been selected as a "frontier" point, we treat it as being empty."""

	return ( self.grid[y][x] == 0 ) or ( self.grid[y][x] == Prim.FRONTIER )
        

    def metadata(self,):
        """Override metadata to inform what type of maze we are carving"""
        return Maze.metadata(self,) + " [Prim]"

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
m = Prim(w,h,s,a,d)
m.draw()
