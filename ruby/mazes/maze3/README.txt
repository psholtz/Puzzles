+ ===================== +
+ PRIM'S ALGORITHM MAZE +
+ ===================== +

Prim's algorithm is a greedy algorithm that finds a minimum spanning tree for a connected weighted undirected graph. With a few simple modifications, it can also be used to generate some pretty slick ASCII mazes as well.

For the sake of efficiency, we'll label the set of all cells which are _not_ yet in the maze, but which are adjacent to a cell that _is_ in the maze, as "frontier" cells.

1. Randomly select a grid point in the maze, and add it to the maze.
2. Update the set of frontier cells.
3. Randomly select a frontier cell, and add it to the maze.
4. "Knock down" the wall between these two cells.
5. Go back to Step 2, and repeat until threre are no more frontier cells.

The algorithm terminates when there are no more frontier cells to choose from.

The algorithm is straightforward, but it tends to leave an abundance of short cul-de-sacs in the maze.

Run the maze with default settings:
> ./maze.rb

Run the maze with custom width and height:
> ./maze.rb -w20 -h25

Run the maze with preet seed, to model deterministic behavior:
> ./maze.rb -s100

Run the maze in animation mode (<-- VERY COOL):
> ./maze.rb -a
