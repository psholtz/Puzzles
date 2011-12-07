Prim's Greedy Algorithm
=======================

Prim's algorithm is a greedy algorithm that finds a minimum spanning tree for a connected weighted unidireted graph. With a few simple modifications, it can also be used to generate some pretty slick ASCII mazes as well.

For the sake of efficiency, we'll label the set of all cells which are _not_ yet in the maze, but which are adjacent to a cell that _is_ in the maze, as "frontier" cells.

1. Randomly select a grid point in the maze, and add it to the maze.