+ ======================== +
+ KRUSKAL'S ALGORITHM MAZE +
+ ======================== +

Kruskal's algorithm is a greedy algorithm in graph theory that finds a minimum spanning tree for a connected weighted graph. With a few modifications, we can use a randomized version of this algorithm to generate some pretty slick ASCII mazes as well.

For the sake of ease, we will represent "sets" as a tree data structure, and "connect" graphs by adding subtrees to a root tree.

1. Design the "walls" between cells as edges in the graph.
2. Randomly select one such edge.
3. If the selected edge connects two disjoint trees, join the trees.
4. Otherwise, throw the edge away.
5. Repeat at Step 2.

The algorithm terminates when there are no more unconnected sets.

The algorithm is straightforward, but it tends to leave an abundance of short cul-de-sacs in the mazes.

+ ================== +
+ RUNNING THE SCRIPT +
+ ================== +

Run the maze with default settings:
> ./maze.rb

Run the maze with custom width and height:
> ./maze.rb -w20 -h15

Run the maze with a preset seed, to model deterministic behavior:
> ./maze.rb -s100

Run the maze in animation mode (<-- VERY COOL):
> ./maze.rb -a

Run the maze with a custom animation delay:
> ./maze.rb -a -d0.05
