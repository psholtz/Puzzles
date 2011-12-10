Prim's Algorithm
================

Prim's algorithm is a greedy algorithm that finds a minimum spanning tree for a connected weighted unidirected graph. With a few simple modifications, it can also be used to generate some pretty slick ASCII mazes as well. More information on Prim's is available here: http://en.wikipedia.org/wiki/Prim's_algorithm

For the sake of efficiency, we'll label the set of all cells which are _not_ yet in the maze, but which are adjacent to a cell that _is_ in the maze, as "frontier" cells.

1. Randomly select a grid point in the maze, and add it to the maze.
2. Update the set of frontier cells.
3. Randomly select a frontier cell, and add it to the maze.
4. "Knock down" the wall between these two cells.
5. Go back to Step 2, and repeat until there are no more frontier cells.

The algorithm terminates when there are no more frontier cells to choose from.

The algorithm is straightforward, but it tends to leave an abundance of short cul-de-sacs in the maze.

Sample Maze
-----------

[![](http://farm8.staticflickr.com/7174/6472763263_cbe4dfc036_m.jpg)](http://farm8.staticflickr.com/7174/6472763263_cbe4dfc036_m.jpg)
