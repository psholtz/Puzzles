#!/usr/bin/php
<?php

$DEFAULT_WIDTH = 10;
$DEFAULT_HEIGHT = 10;
$DEFAULT_SEED = make_seed();
$DEFAULT_ANIMATE = false;
$DEFAULT_DELAY = 0.02;

// random seed generator for PHP
function make_seed()
{
	list($usec,$sec) = explode(' ',microtime());
	return (float)$sec + ((float)$usec * 100000);
}

// ==================================================================
// Class Maze defines basic behavior to which a maze should conform.
// It provides basic initialization/construction for the maze class, 
// and provides a method for drawing ASCII mazes.
//
// Specific "maze-carving" techniques are implemented in subclasses.
// ==================================================================
class Maze
{
	// static variables indicating directions
	public static $N = 1;	      
	public static $S = 2;
	public static $E = 4;
	public static $W = 8;

	// wrap DX, DY, OPPOSITE as static functions, since otherwise hard to get, e.g., self::$E reference
	public static function DX() { return array(self::$E => +1, self::$W => -1, self::$N => 0, self::$S => 0); }
	public static function DY() { return array(self::$E => 0, self::$W => 0, self::$N => -1, self::$S => +1); }
	public static function OPPOSITE() { return array(self::$E => self::$W, self::$W => self::$E, self::$N => self::$S, self::$S => self::$N ); }

	// instance variables for maze
	public $width;
	public $height;
	public $seed;

	// data structure for maze itself
	protected $grid;

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Construct a new 2D maze with the given width and height.
	//
	// Default seed value will give "random" behavior.
	// User-supplied seed value will give deterministic behavior.
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function __construct($w=NULL, $h=NULL, $s=NULL) {
	    // import the global variables
	    global $DEFAULT_WIDTH, $DEFAULT_HEIGHT, $DEFAULT_SEED;

	    // configure the instance variables
	    $this->width = is_null($w) ? $DEFAULT_WIDTH : $w;
	    $this->height = is_null($h) ? $DEFAULT_HEIGHT : $h;
	    $this->seed = is_null($s) ? $DEFAULT_SEED : $s;

	    // seed the PRNG
	    srand($this->seed);
 
	    // initialize two-dimensional grid representing maze 
	    $this->grid = array();
	    for ( $j=0; $j < $this->height; ++$j ) {
	    	$temp = array();
		for ( $i=0; $i < $this->width; ++$i ) {
		    array_push($temp,0);
		}
		array_push($this->grid,$temp);
	    }
	}
	
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Draw the grid, starting in the upper-left hand corner.
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function draw() {
	    // draw the top row
	    $buffer = array();
	    $out = " ";
	    for ( $i=0; $i < (2 * $this->width - 1); ++$i ) {
	    	$out .= "_";
	    }
	    array_push($buffer,$out);

	    // draw each row of the maze
	    for ( $j=0; $j < $this->height; ++$j ) {
	        $out = "|";
		for ( $i=0; $i < $this->width; ++$i ) {
		    // render the bottom
		    $out .= (($this->grid[$j][$i] & self::$S) != 0) ? " " : "_";

		    // render the side
		    if ( ($this->grid[$j][$i] & self::$E) != 0 ) {
		        $out .= ( ( $this->grid[$j][$i] | $this->grid[$j][$i+1] ) & self::$S ) != 0 ? " " : "_";
		    } else {
		        $out .= "|";
		    }
		}
		array_push($buffer,$out);
	    }

	    //
	    // Add the metadata
	    //
	    // NOTE: We must call this with $this->metadata() to get the correct OO behavior we expect.
	    // Calling it with self::metadata() will invoke "this" classes metadata() method, not the 
	    // child classes, which is *not* the behavior we desire.
	    //
	    array_push($buffer, $this->metadata());
	    array_push($buffer, "");
	    
	    // flush the buffer
	    echo join($buffer, "\r\n");
	}
	
	// ++++++++++++++++++++++++++++++++
	// Generate generic maze metadata.
	// ++++++++++++++++++++++++++++++++ 
	function metadata() {
	    // take the global arguments
	    global $argv;
	    
	    // used array to buffer output
	    $buffer = "";
	    $temp = array($argv[0], $this->width, $this->height, $this-> seed);
	    $buffer .= join($temp, " ");

	    // return the buffer
	    return $buffer;	    
	}
}

// ==========================================================================
// Class BackTracker implements a simple recursive back-tracking algorithm
// to draw ASCII mazes. The algorithm works as a "depth-first" search
// of the "tree" or "graph" representing the maze.
//
// A possible optimization might be to implement a "breadth-first" search.
// ==========================================================================
class BackTracker extends Maze 
{
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Initialize a new 2D maze with the given width and height.
	//
	// Default seed value will give "random" behavior.
	// User-supplied seed value will given deterministic behavior.
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function __construct($w=NULL, $h=NULL, $s=NULL, $a=false, $d=NULL) {
	    //
	    // Invoke super-constructor
	    //
	    parent::__construct($w,$h,$s);

	    //
	    // Only prepare the maze if we are doing "static" (i.e., animate=false) drawing
	    //
	    $this->delay = $d;
	    $this->animate = $a;
	    if ( !$this->animate ) {
	        self::carve_passage_from(0,0);
	    }
	}

	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Recursively carve passages through the maze, starting at (x,y).
	//
	// Algorithm halts when all "cells" in the maze have been visited.
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function carve_passage_from($x,$y) {
	    // randomize the directions
	    $directions = array(self::$N, self::$S, self::$E, self::$W);
	    shuffle($directions);

	    $DX = self::DX();
	    $DY = self::DY();
	    $OPPOSITE = self::OPPOSITE();

	    for ( $i=0; $i < sizeof($directions); ++$i ) {
	    	// 
		// Render updates of the maze on a "cell-by-cell" basis
		//
		if ( $this->animate ) {
		    $this->display($x,$y);
		    usleep(1000000*$this->delay);
		}

	    	$direction = $directions[$i];
		$dx = $x + $DX[$direction];
		$dy = $y + $DY[$direction];
		if ( $dy >= 0 && $dy < $this->height && $dx >= 0 && $dx < $this->width && $this->grid[$dy][$dx] == 0 ) {
		   $this->grid[$y][$x] |= $direction;
		   $this->grid[$dy][$dx] |= $OPPOSITE[$direction];
		   $this->carve_passage_from($dx,$dy);
		}
	    }

	    //
	    // Make one final call to "update" to display the last cell.
	    // Set the coords to (-1,-1) so the cell is left "blank" with no cursor.
	    //
	    if ( $this->animate ) {
	        $this->display(-1,-1);
	    }
	}

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Method only needs to be overridden if we are animating.
	# 
	# If we are drawing the maze statically, defer to the superclass.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function draw() {
	
	    //
	    // Clear the screen
	    //
	    echo sprintf("%c[2J",27);
	    if ( !$this->animate ) {
	       
	        //
		// Move to upper left and defer to superclass
		//
		echo sprintf("%c[H",27);
		parent::draw();
	    } else {
	        //
		// If we are animating, clear the screen and start carving!
		//
		$this->carve_passage_from(0,0);

		//
		// Output maze metadata
		//
		echo $this->metadata();
		echo "\r\n";
	    }
	}

	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Display needs the (x,y) coordinates of where it is presently rendering, in 
	# order to color the "current cursor" cell a different color (in this case, 
	# red). We've already used the symbols "x" and "y" in a previous implementation
	# of this algorithm, so we'll name them "i" and "j" in the method signature instead.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function display($i,$j) {
	    //
	    // Clear the screen and draw the top row
	    //
	    echo sprintf("%c[H",27);
	    $buffer = array();
	    $out = " ";
	    for ( $c=0; $c < (2 * $this->width - 1); ++$c ) {
	        $out .= "_";
	    }
	    array_push($buffer, $out);

	    // 
	    // Step through each cell of the array
	    //
	    for ( $y=0; $y < $this->height; ++$y ) {
	    	$out = "|";
		for ( $x=0; $x < $this->width; ++$x ) {
		    // 
		    // Color gray if empty, red if "current" cursor
		    // 
		    if ( $this->grid[$y][$x] == 0 ) {
		        //$out .= sprintf("%c[47m",27);
		    } else if ( $x == $i && $y == $j ) {
		        $out .= sprintf("%c[41m",27);
		    }

		    // render the bottom using the "S" switch
		    $out .= (($this->grid[$y][$x] & self::$S) != 0) ? " " : "_";

		    // render the side using the "E" switch
		    if ( ($this->grid[$y][$x] & self::$E) != 0 ) { 
		        $out .= ((($this->grid[$y][$x] | $this->grid[$y][$x+1]) & self::$S) != 0)  ? " " : "_";
		    } else {
		        $out .= "|";
		    }

		    // 
		    // Stop coloring
		    // 
		    if ( $this->grid[$y][$x] || ( $x == $i && $y == $j ) ) { 
		        $out .= sprintf("%c[m",27);
		    }
		}
		array_push($buffer,$out);
	    }
			    
	    // Flush the buffer
	    array_push($buffer,"");
	    echo join($buffer, "\r\n");
	}

	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	// Override metadata to inform what type of maze we are carving.
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function metadata() {
	    return parent::metadata() . " [BackTracker]";
	}
}

//
// Build and draw a new maze
//
$maze = new BackTracker(10,10,NULL,true,0.02);
$maze->draw();
?>