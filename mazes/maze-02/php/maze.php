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
	    array_push($buffer, $out);

	    // draw each row of the maze
	    for ( $j=0; $j < $this->height; ++$j ) {
	    	$out = "|";
		for ( $i=0; $i < $this->width; ++$i ) {
		    // render the bottom
		    $out .= (($this->grid[$j][$i] & self::$S) != 0) ? " " : "_";

		    // render the side
		    if ( ( $this->grid[$j][$i] & self::$S) != 0 ) {
		        $out .= ( ( $this->grid[$j][$i] | $this->grid[$j][$i+1] ) & self::$S ) != 0 ? " " : "_";
		    } else {
		        $out .= "|";
		    }
		}
		array_push($buffer, $out);
	    }

	    // add metadata
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

	    // use array to buffer output
	    $buffer = "";
	    $temp = array($argv[0], $this->width, $this->height, $this->seed);
	    $buffer .= join($temp, " ");
    
	    // return the buffer
	    return $buffer;
	}
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Class BinaryTree implements a simple binary tree algorithm to draw simple ASCII mazes.
//  
//  1. Start in the upper-left cell of the maze.
//  2. Randomly carve either towards the east or south.
//
// And that's it!
//
// The algorithm is fast and simple, but has two significant drawbacks: (a) two of the four
// sides (in this case, the north and west) will be spanned by a single corridor; and (b) 
// the maze will exhibit a strong diagonal bias (in this case, north-west to south-east).
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class BinaryTree extends Maze
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
	}

	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
	// Override metadata to inform what type of maze we are carving.
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function metadata() {
	    return parent::metadata() . " [BinaryTree]";
	}
}

//
// Configure default values for the variables
//
$_width	  = $DEFAULT_WIDTH;
$_height  = $DEFAULT_HEIGHT;
$_seed    = $DEFAULT_SEED;
$_animate = $DEFAULT_ANIMATE;
$_delay   = $DEFAULT_DELAY;

//
// Do extremely simple, "optparse" style parsing of the command line input
//
if ( sizeof($argv) > 1 ) {
    for ( $i=1; $i < sizeof($argv); ++$i ) {
        $arg = $argv[$i];

	// parse the "argument" parameters
	if ( strlen($arg) > 2 ) {
	    $s = substr($arg,0,1);
	    $t = substr($arg,1,1);
	    if ( $s == "-" ) {
	        if ( $t == "w" ) {
		    $tmp = intval(substr($arg,2));
		    $_width = $tmp > 0 ? $tmp : $DEFAULT_WIDTH;
		}
		else if ( $t == "h" ) {
		    $tmp = intval(substr($arg,2));
		    $_height = $tmp > 0 ? $tmp : $DEFAULT_HEIGHT;
		}
		else if ( $t == "d" ) {
		    $tmp = floatval(substr($arg,2));
		    $_delay = $tmp > 0 ? $tmp : $DEFAULT_DELAY;
		}
	    }
	}

	// parse the "no argument" parameters
	else if ( strlen($atg) > 1 ) {
	    $s = substr($arg,0,1);
	    $t = substr($arg,1,1);
	    if ( $s == "-" ) {
	        if ( $t == "a" ) {
		    $_animate = true;
		}
	    }
	}	
    }     
}

//
// Build and draw a new maze
//
$maze = new BinaryTree($_width, $_height, $_seed, $_animate, $_delay);
$maze->draw();
?>