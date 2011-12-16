Running the Script
==================

Run the maze with default settings:
<pre>
> ./maze.rb
</pre>

Run the maze with custom width and height:
<pre>
> ./maze.rb -w20 -h15
</pre>

Run the maze with a preset seed, to model deterministic behavior:
<pre>
> ./maze.rb -s100
</pre>

Run the maze in animation mode:
<pre>
> ./maze.rb -a
</pre>

Run the maze with a custom animation delay:
<pre>
> ./maze.rb -a -d0.05
</pre>

Run the maze with a custom cell selection method:
<pre>
> ./maze.rb -m"random;oldest:40,newest:60"
</pre>