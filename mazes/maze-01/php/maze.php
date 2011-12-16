#!/usr/bin/php
<?php

$DEFAULT_WIDTH = 10;
$DEFAULT_HEIGHT = 10;
$DEFAULT_SEED = make_seed();

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
		 echo "here\r\n";
	}
	
	// ++++++++++++++++++++++++++++++++
	// Generate generic maze metadata.
	// ++++++++++++++++++++++++++++++++ 
	function metadata() {

	}
}

class BackTracker extends Maze 
{

}

//
// Build and draw a new maze
//
$maze = new BackTracker();
$maze->draw();
?>