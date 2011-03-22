+ ====================== +
+ GROWING TREE ALGORITHM +
+ ====================== +

The Growing Tree algorithm is in principle quite simple:

1. Let C be a list of cells, initially empty.
2. Add one cell to C, at random.
3. Choose a cell from C, and carve a passage to any unvisited neighbor of that cell, 
   adding that neighbor to C as wel. If there are no unvisited neighbors, remove the 
   cell from C.
4. Repeat (3) until C is empty.

The interesting part of the algorithm is in how you choose the cells from C, in step #3.
If you always choose the newest cell, you'll get the recursive backtracking algorithm. 
If you always choose a cell at random, you'll get Prim's.

+ ================== +
+ RUNNING THE SCRIPT +
+ ================== +

Run the maze with default settings:
> ./maze.rb

Run the maze with custom width and height:
> ./maze.rb -w20 -h15

Run the maze with a preset seed, to model deterministic behavior:
> ./maze.rb -s100

Run the maze in animation mode (<-- COOL)
> ./maze.rb -a

Run the maze with a custom animation delay:
> ./maze.rb -a -d0.05

Run the maze with a custom cell selection method:
> ./maze.rb -m"random;oldest:40,newest:60"

