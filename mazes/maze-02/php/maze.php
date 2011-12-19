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
		    if ( ($this->grid[$j][$i] & self::$E) != 0 ) {
		       $out .= ( ($this->grid[$j][$i] | $this->grid[$j][$i+1]) & self::$S ) != 0 ? " " : "_";
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

	    //
	    // Only prepare the maze if we are doing "static" (i.e., animate=false) drawing
	    //
	    $this->delay = $d;
	    $this->animate = $a;
	    if ( !$this->animate ) {
	        $this->carve_passages();
	    }
	}

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Walk down the maze, cell-by-cell, carving a maze using the binary tree algorithm.
	//
	// Because we walk down the maze, cell-by-cell, in a linear fashion, this
	// algorithm is amenable to animation. Animated version is implemented in ths 
	// overridden draw() method below.
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function carve_passages() {

	    // 
	    // Get references to static variables/functions that we need
	    //
	    $DX = self::DX();
	    $DY = self::DY();
	    $OPPOSITE = self::OPPOSITE();

	    // 
	    // Step through the grid of the maze
	    //
	    for ( $y=0; $y < $this->height; ++$y ) {
	        for ( $x=0; $x < $this->width; ++$x ) {
		    //
		    // Render updates of maze on a "cell-by-cell" basis
		    //
		    if ( $this->animate ) {
		        $this->display($x,$y);
			usleep(1000000*$this->delay);
		    }

		    $dirs = array();
		    if ( $y > 0 ) { array_push($dirs,self::$N); }
		    if ( $x > 0 ) { array_push($dirs,self::$W); }

		    if ( sizeof($dirs) > 0 ) {		    
		    $dir = $dirs[rand(0,sizeof($dirs)-1)];
		    if ( $dir > 0 ) {
		       $dx = $x + $DX[$dir];
		       $dy = $y + $DY[$dir];
		       $this->grid[$y][$x] |= $dir;
		       $this->grid[$dy][$dx] |= $OPPOSITE[$dir];
		    }
		    }
		}
	    }

	    // 
	    // Make one final call to "update" to display the last cel;
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
		// If we are animating, clear the screen and start carving:
		//
		$this->carve_passages(0,0);
		
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
	    // Draw the "top" line
	    //
	    echo sprintf("%c[H",27);
	    $buffer = array();
	    $out = " ";
	    for ( $c=0; $c < (2 * $this->width -1); ++$c ) {
	        $out .= "_";
	    }
	    array_push($buffer,$out);

	    //
	    // Step through the grid, one cell at a time
	    //
	    for ( $y=0; $y < $this->height; ++$y ) {
	        $out = "|";
		for ( $x=0; $x < $this->width; ++$x ) {
		    // Color if necessary
		    if ( $this->grid[$y][$x] == 0 ) {
		        $out .= sprintf("%c[47m",27);
		    }
		    if ( $x == $i && $y == $j ) {
		        $out .= sprintf("%c[41m",27);
		    }

		    // Render "bottom" using "S" switch
		    $out .= (($this->grid[$y][$x] && self::$S) != 0) ? " " : "_";

		    //  Render "side" using "E" switch
		    if ( ( $this->grid[$y][$x] & self::$S) != 0 ) {
		        $out .= "*";
//		        $out .= ((($this->grid[$y][$x] | $this->grid[$y][$x+1]) & self::$S) != 0) ? " " : "_";
		    } else {
		        $out .= "|";
		    }

		    // Stop coloring
		    if ( $this->grid[$y][$x] == 0 || ( $x == $i && $y == $j ) ) {
		        $out .= sprintf("%c[m",27);
		    }
		}
		array_push($buffer,$out);
	    }
	    array_push($buffer,"");

	    echo join($buffer,"\r\n");
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
		else if ( $t == "s" ) {
		    $tmp = intval(substr($arg,2));
		    $_seed = $tmp > 0 ? $tmp : $DEFAULT_SEED;
		}
		else if ( $t == "d" ) {
		    $tmp = floatval(substr($arg,2));
		    $_delay = $tmp > 0 ? $tmp : $DEFAULT_DELAY;
		}
	    }
	}

	// parse the "no argument" parameters
	else if ( strlen($arg) > 1 ) {
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