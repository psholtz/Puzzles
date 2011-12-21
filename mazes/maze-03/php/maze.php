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
	    	$tmp = array();
		for ( $i=0; $i < $this->width; ++$i ) {
		   array_push($tmp,0);
		}
		array_push($this->grid,$tmp);
	    }
	}

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Draw the grid, starting in the upper-left hand corner.
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function draw() {
   	   // draw the top row
	   $buffer = array();
	   $out = " ";
	   for ( $i=0; $i < (2*$this->width-1); ++$i ) {
	      $out .= "_";
	   }
	   array_push($buffer, $out);

	   // 
	   // Step through the grid of the maze
	   //
	   for ( $j=0; $j < $this->height; ++$j ) {
	      $out = "|";
	      for ( $i=0; $i < $this->width; ++$i ) {
	         // render the bottom
		 $out .= (($this->grid[$j][$i] & self::$S) != 0) ? " " : "_";

		 // render the side
		 if ( ( $this->grid[$j][$i] & self::$E ) != 0 ) { 
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

	// +++++++++++++++++++++++++++++++
	// Generate generic maze metadata
	// +++++++++++++++++++++++++++++++
	function metadata() {
	   // take the global arguments
	   global $argv;

	   // use array to buffer output
	   $buffer = "";
	   $tmp = array($argv[0], $this-width, $this->height, $this->seed);
	   $buffer .= join($tmp, " ");

	   // return the buffer
	   return $buffer;
	} 
}

class Prim extends Maze
{     
	// +++++++++++++++++++++++++++ 
	// Configure class variables
	// +++++++++++++++++++++++++++ 
	public static $IN = 0x10;
	public static $FRONTIER = 0x20;

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

	    $this->frontier = array();

	    // 
	    // Only prepare the maze if we are doing "static" (i.e., animate=false) drawing
	    //
	    $this->delay = $d;
	    $this->animate = $a;
	    if ( !$this->animate ) { 
	       $this->carve_passages();
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
	     // If we are animating, clear the screen adn start carving!
	     //
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
	    // Select random point in the grid to begin carving
	    //
	    $this->mark( rand(0, $this->width), rand(0, $this->height) );

	    $OPPOSITE = self::OPPOSITE();

	    //
	    // Marking an empty matrix creates a front.
	    // Keep going until there is no frontier.
	    //
	    //while ( sizeof($this->frontier) > 0 ) {
	    for ( $qq =0 ; $qq < 150; $qq++ ) {
	        //
   		// Randomly select a frontier point, and 
		// randomly select one of the neighboring
		// points to that frontier piece.
		//

	        //
		// Pluck the point from the frontier
		//
	        $index = rand(0, sizeof($this->frontier) );	
		$point = $this->frontier[$index];
		unset($this->frontier[$index]);
		$x = $point[0]; $y = $point[1];
		
		//
		// Pluck the point from the neighbhors 
		//
		$n = $this->neighbors($x, $y);
		$index = rand(0, sizeof($n)); 
		$point = $n[$index]; 
		$nx = $point[0]; $ny = $point[1];

		//
		// Knock down the wall between the selected
		// frontier point and its neighbor.
		//
		$dir = $this->direction($x, $y, $nx, $ny);
		$this->grid[$y][$x] |= $dir;
		$this->grid[$ny][$nx] |= $OPPOSITE[$dir];
		
		// 
		// Recursively mark the newly selected point.
		//
		$this->mark($x, $y);
		
		//
		// If we are animating, display the maze
		//
		if ( $this->animate ) {
		   $this->display();
		   usleep(1000000*$this->delay);
		}
}
	    //}
	  
	    //
	    // If we are animating, display the maze (one last time)
	    //
	    if ( $this->animate ) {
	        $this->display();

		//
		// Output maze metadata
		//
		echo $this->metadata();
		echo "\r\n";
	    }
	}

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Invoked to render animated version of the ASCII maze
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++
	function display() {
	    //
	    // Draw the "top row" of the maze
	    //
	    echo sprintf("%c[H",27);
	    $buffer = array();
	    $out = " ";
	    for ( $c=0; $c < (2 * $this->width - 1); ++$c ) {
	        $out .= "_";
	    }
	    array_push($buffer, $out);

	    // 
	    // Step through the grid cells of the maze
	    //
	    for ( $y=0; $y < $this->height; ++$y ) {
	    	$out = "|";
		for ( $x=0 ; $x < $this->width; ++$x ) {
		    // 
		    // Color the cell if it is frontier
		    //
		    $cell = $this->grid[$y][$x];
		    if ( $cell == self::$FRONTIER ) { $out .= sprintf("%c[41m",27); }
		    if ( $this->isEmpty($cell) && $y+1 < $this->height && $this->isEmpty($this->grid[$y+1][$x]) ) {
		       $out .= " ";
		    } else {
		       $out .= (($cell & self::$S) != 0) ? " " : "_";
		    }
		    if ( $cell == self::$FRONTIER ) { $out .= sprintf("%c[m",27); }
		    
		    // 
		    // Draw the "grid" of the maze
		    //
		    if ( $this->isEmpty($cell) && $x+1 < $this->width && $this->isEmpty($this->grid[$y][$x+1]) ) {
		        $out .= ($y+1 < $this->height) && ( $this->isEmpty($this->grid[$y+1][$s]) || $this->isEmpty($this->grid[$y+1][$x+1]) )  ? " " : "_";
		    } else if ( ($cell & self::$E) != 0 ) {
		        $out .= (($cell | $this->grid[$y][$x+1]) & self::$S) != 0 ? " " : "_";
		    } else {
		        $out .= "|";
		    }
		}
		array_push($buffer, $out);
	    }
	    array_push($buffer, "");

	    //
	    // Flush the buffer
	    //
	    echo join($buffer, "\r\n");
	}
	
	// +++++++++++++++++++++++++++++++++++++++++ 
	// Add the grid point (x,y) to the frontier 
	// so long as its within bounds and empty.
	// +++++++++++++++++++++++++++++++++++++++++ 
	function add_to_frontier($x, $y) {
	    if ( $x >= 0 && $y >= 0 && $y <= $this->height && $x <= $this->width && $this->grid[$y][$x] == 0 ) { 
	        $this->grid[$y][$x] |= self::$FRONTIER;
		array_push($this->frontier,array($x,$y));
	    }
	}

	// +++++++++++++++++++++++++++++++++++++++++++ 
	// Add the grid point (x,y) to the maze, and
	// add its neighboring points to the frontier
	// +++++++++++++++++++++++++++++++++++++++++++ 
	function mark($x, $y) {
	    $this->grid[$y][$x] |= self::$IN; 

	    $this->add_to_frontier( $x-1, $y );
	    $this->add_to_frontier( $x+1, $y );
	    $this->add_to_frontier( $x, $y-1 );
	    $this->add_to_frontier( $x, $y+1 );
	}

	// +++++++++++++++++++++++++++++++++++++++++++++
	// Find the points which are inbounds and which	
	// have not yet been added to the matrix.
	// +++++++++++++++++++++++++++++++++++++++++++++ 
	function neighbors($x, $y) {
	    $n = array();

	    if ( $x > 0 && ($this->grid[$y][$x-1] & self::$IN) != 0 )		       { array_push($n, array($x-1,$y)); }
	    if ( $x+1 < $this->width && ($this->grid[$y][$x+1] & self::$IN) != 0 )     { array_push($n, array($x+1,$y)); }
	    if ( $y > 0 && ($this->grid[$y-1][$x] & self::$IN) != 0 )	       	       { array_push($n, array($x,$y-1)); }
	    if ( $y+1 < $this->height && ($this->grid[$y+1][$x] & self::$IN) != 0 )    { array_push($n, array($x,$y+1)); }

	    return $n;
	}

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Decide the direction we are moving in.
	//
	// Answer will be one of the class variables N, S, E and W.
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function direction($fx, $fy, $tx, $ty) {
	    if ( $fx < $tx ) { return self::$E; }
	    if ( $fx > $tx ) { return self::$W; }
	    if ( $fy < $ty ) { return self::$S; }
	    if ( $fy > $ty ) { return self::$N; }
	}

	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// If the cell is empty (i.e., 0) or has been selected
	// as a "frontier" point, we treat it is being empty.
	// (Note: "empty" is a reserved keyword/function in PHP)
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function isEmpty($cell) { 
	    return $cell == 0 || $cell == self::$FRONTIER;
	}

	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
	// Override metadata to inform what type of maze we are carving.
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	function metadata() {
	   return parent::metadata() . " [Prim]";
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
$maze = new Prim($_width, $_height, $_seed, $_animate, $_delay);
$maze->draw();
?>