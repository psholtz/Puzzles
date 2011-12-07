import java.util.ArrayList;
import java.util.List;

public class Prim extends Maze {
	
	// define class variables
	public static int IN = 0x10;
	public static int FRONTIER = 0x20;
	
	// define instance variables
	private boolean _animate = false;
	private float _delay = 0.0f;
	private List<Point> _frontier = null;
	
	//
	// Standard Constructors
	//
	public Prim() {
		super();
		initialize();
	}
	public Prim(int w,int h) {
		super(w,h);
		initialize();
	}
	public Prim(int w,int h,long seed) {
		super(w,h,seed);
		initialize(); 
	}
	
	// 
	// Animating Constructor(s)
	//
	public Prim(int w,int h,boolean animate,float delay) {
		super(w,h);
		_animate = animate;
		_delay = delay;
		initialize();
	}

	public Prim(int w,int h,boolean animate,float delay,long seed) {
		super(w,h,seed);
		_animate = animate;
		_delay = delay;
		initialize();
	}

	private void initialize() {
		// structure to hold the frontier cells
		_frontier = new ArrayList<Point>();
		
		// only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		if ( !_animate ) {
			carvePassages(); 
		}
	}
	
	/***************************************************************
	 * Carve the passages in the maze using the Prim algorithm.
	 ***************************************************************/
	private void carvePassages() {
		
		// if we are animating, display the maze (one last time)
		if ( _animate ) {
			display();
			
			// output maze metadata 
			outputMetadata();
		}
	}
	
	/****************************************************************
	 * Method only needs to be overridden if we are animating.
	 * 
	 * If we are drawing the maze statically, defer to superclass. 
	 ***************************************************************/
	public void draw() {
		// clear the screen
		System.out.print((char)27 + "[2J");
		
		if ( !_animate ) {
			// move to upper left and defer to superclass
			System.out.print((char)27 + "[H");
			super.draw();
		} else {
			// if we are animating, clear the screen and start carving
			carvePassages(); 
		}
	}
	
	/********************************************************* 
	 * Invoked to render animated version of the ASCII maze.
	 *********************************************************/
	public void display() {
		// draw the "top raw" of the maze
		System.out.print((char)27 + "H[");
		System.out.print(" ");
		for ( int i=0; i < (_w*2) - 1; ++i ) {
			System.out.print("_");
		}
		System.out.println("");
	}
	
	/************************************************************************************
	 * Add the grid point (x,y) to the frontier so long as its within bounds and empty.
	 * 
	 * @param x x-coord of the point to add to the frontier.
	 * @param y y-coord of the point to add to the frontier.
	 ***********************************************************************************/
	private void addToFrontier(int x, int y) {
		if ( x >= 0 && y >= 0 && y < _h && x < _w && _grid[y][x] == 0 ) {
			_grid[y][x] |= Prim.FRONTIER;
			_frontier.add(new Point(x,y));
		}
	}
	
	/****************************************************************************************
	 * Add the grid point (x,y) to the maze, and add its neighboring points to the frontier.
	 * 
	 * @param x x-coord of the point to add to the maze.
	 * @param y y-coord of the point to add to the maze. 
	 ****************************************************************************************/
	private void mark(int x, int y) {
		_grid[y][x] |= Prim.IN;
		
		addToFrontier( x-1, y );
		addToFrontier( x+1, y );
		addToFrontier( x, y-1 );
		addToFrontier( x, y+1 );
	}
	
	/***************************************************************************************
	 * Find the bounds which are inbounds and which have not yet been added to the matrix.
	 * 
	 * @param x
	 * @param y
	 * @return
	 **************************************************************************************/
	private List<Point> neighbors(int x,int y) {
		ArrayList<Point> n = new ArrayList<Point>();
		
		return n;
	}
	
	/************************************************************************************
	 * Decide on which direction we should be moving in.
	 * 
	 * The answer will be one of the class variables N, S, E or W.
	 * 
	 * @param fx
	 * @param fy
	 * @param tx
	 * @param ty
	 * @return Maze.N, Maze.S, Maze.E or Maze.W depending on which direction to go. 
	 ***********************************************************************************/
	private int direction(int fx, int fy, int tx, int ty) {
		if ( fx < tx ) return Maze.E;
		if ( fx > tx ) return Maze.W;
		if ( fy < ty ) return Maze.S;
		if ( fy > ty ) return Maze.N;
		
		// default case, should not get here.. 
		return -1;
	}
	
	/**********************************************************************************************
	 * If the cell contents are empty (i.e., 0), or if the cell has been selected as a "frontier"
	 * point, we treat it as being empty.
	 * 
	 * @param cell int representing the contents of the cell. 
	 * @return true if the cell is empty or in the frontier, otherwise false
	 *********************************************************************************************/
	private boolean empty(int cell) {
		return cell == 0 || cell == Prim.FRONTIER;
	}
}

/********************************************************************************************
 * Container object to hold a representation of points, so that we can store and manipulate 
 * "point" objects in java.util.List structures.
 * 
 * @author psholtz
 *******************************************************************************************/
class Point {
	private int _x;
	private int _y;
	
	public Point(int x,int y) {
		_x = x;
		_y = y;
	}
	
	public int getX() { return _x; }
	public int getY() { return _y; }
}