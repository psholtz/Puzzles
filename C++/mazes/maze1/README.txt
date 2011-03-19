+ =========================== +
+ RECURSIVE BACKTRACKING MAZE +
+ =========================== +

Class Maze implements a simple recursive backtracking algorithm to draw simple ASCII mazes. 

Maze "state" is maintained in a structure called _grid.

Grid entries can have values between 0 and 15 [ 2^(number-of-walls=4)-1 ]

If a grid entry has value 0, this means all four walls are "intact".  This is the condition into which we initialize the maze, but once the algorithm has run and the maze has been created, all entries should have values between 1 and 15.

We assign the following values to "north", "south", "east" and "west" directions:

 (N,S,E,W) = (1,2,4,8)

Note that this scheme can easily be extended to three dimensions, by assigning values 16 and 32 to "up" and "down" respectively.

The algorithm itself is a simple recursive backtracking scheme:

 - Choose a starting point in the grid;
 - Randomly choose a wall to "knock down";
 - "Knock down" and carve a path to the adjacent cell, but only if the adjacent cell has NOT yet been visited;
 - Once ALL adjacent cells have been visited, back up to the last cell that has uncarved cells and repeat;
 - The algorithm ends when the process has backed up all the way;

The algorithm is a "depth-first" traversal of the grid. The intuition is that the maze is an undirected graph and the algorithm will construct the maze by traversing that graph in depth-first order. It's a straightforward approach, but it requires a stack size proportional to the longest acyclic path through the maze, which in the worst case is the entire maze itself.

A possible "optimization" would be to implement a breadth-first traversal.

+ ================== +
+ RUNNING THE SCRIPT +
+ ================== +

Run the maze with default settings:
> ./maze

Run the maze with custom width and height:
> ./maze -w20 -h25

Run the maze with a preset seed, to model deterministic behavior:
> ./maze -s100

