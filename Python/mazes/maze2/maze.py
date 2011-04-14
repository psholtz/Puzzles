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
    out = " ".join([sys.argv[0],str(self.width),str(self.height),str(self.seed)])
    buffer.append(out)

    print "\r\n".join(buffer)

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
                  self.draw(True)
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
          self.draw(True)

  def draw(self,update=False):
      if update or not self.animate:
          sys.stdout.write("\x1b[H")
          if not self.animate:
              sys.stdout.write("\x1b[2J")
          Maze.draw(self,)
      else:
          sys.stdout.write("\x1b[2J")
          BinaryTree.carve_passages(self)

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

