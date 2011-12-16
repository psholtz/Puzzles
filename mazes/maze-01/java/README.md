Running the Program
------------------- 

Fist compile the Driver.java file using "javac". 

To run the maze with default settings: 
<pre>
> java Driver
</pre>

To run the maze with custom width and height: 
<pre>
> java Driver -w20 -h25
</pre>

To run the maze with a preset seed, to model deterministic behavior: 
<pre>
> java Driver -s100
</pre>

Run the maze in animation mode:
<pre>
> java Driver -a
</pre>

Run the maze with a custom animation delay:
<pre>
> java Driver -a -d0.05
</pre>