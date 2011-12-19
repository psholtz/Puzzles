/*****************************************************************************
 * Class BackTracker implements a simple recursive back-tracking algorithm
 * to draw ASCII mazes. The algorithm works as a "depth-first" search of the 
 * "tree" or "graph" representing the maze.
 *
 * A possible optimization might be to implement a "breadth-first" search.
 *
 * @author psholtz
 *****************************************************************************/

public class BackTracker extends Maze {

    // Define instance variables
    private boolean _animate = false;
    private float _delay = 0.02f;

    /***************************************************************
     * Initialize a new 2D maze with the optional parameters.
     * 
     * Maze implements the recursive back-tracking algorithm. 
     * 
     * @author psholtz
     ***************************************************************/
    // 
    // Standard Constructors
    //
    public BackTracker() {
	super();
	carvePassageFrom(0,0);
	initialize();
    }
    public BackTracker(int w,int h) {
	super(w,h);
	carvePassageFrom(0,0);
	initialize();
    }
    public BackTracker(int w,int h,long seed) {
	super(w,h,seed);
	carvePassageFrom(0,0);
	initialize();
    }

    //
    // Animating Constructors
    //
    public BackTracker(int w,int h,boolean animate,float delay) {
	super(w,h);
	_animate = animate;
	_delay = delay;
	initialize();
    }
    public BackTracker(int w,int h,boolean animate,float delay,long seed) {
	super(w,h,seed);
	_animate = animate;
	_delay = delay;
	initialize();
    }

    private void initialize() {
	// Only prepare the maze beforehand if we are doing "static" (i.e., animate=false) drawing
	if ( !_animate ) {
	    carvePassageFrom(0,0);
	}
    }
	
    //
    // Override metadata to inform what type of maze we are carving.
    //
    protected String metadata() {
	return super.metadata() + " [BackTracker]";
    }

    /********************************************************************
     * Method only needs to be overridden if we are animating.
     *
     * If we are drawing the maze statically, defer to the superclass.
     *******************************************************************/
    public void draw() {
	// Clear the screen
	System.out.print((char)27 + "[2J");
	if ( !_animate ) {
	    // Move to upper left and defer to superclass
	    System.out.print((char)27 + "[H");
	    super.draw();
	} else {
	    // If we are animating, clear the screen and start carving:
	    carvePassageFrom(0,0);

	    // Output maze metadata
	    System.out.println(metadata());
	}
    }

    /***************************************************************************************
     * Display needs the (x,y) coordinates of where it is presently rendering, in 
     * order to color the "Current cursor" cell a different color (in this case, 
     * red). We've already used the symbols "x" and "y" in a previous implementation
     * of this algorithm, so we'll name them "i" and "j" in the method signature instead.
     ***************************************************************************************/
    private void display(int i,int j) {
	// Draw the "top row" of the maze
	System.out.print((char)27 + "[H");
	System.out.print(" ");
	for ( int c=0; c < (_w*2) - 1; ++c ) {
	    System.out.print("_");
	}
	System.out.println("");

	// Step through the cells of the maze
	for ( int y=0; y < _grid.length; ++y ) {
	    System.out.print("|");
	    for ( int x=0; x < _grid[0].length; ++x ) {
		// Color gray if empty, red if "current" cursor
		if ( _grid[y][x] == 0 ) {
		    System.out.print((char)27 + "[47m");
		} else if ( x == i && y == j ) {
		    System.out.print((char)27 + "[41m");
		}

		// Render "bottom" using the "S" switch
		System.out.print((_grid[y][x] & Maze.S) != 0 ? " " : "_");

		// Render "side" using "E" switch
		if ( (_grid[y][x] & Maze.E) != 0 ) {
		    System.out.print((_grid[y][x] & Maze.S) != 0 ? " " : "_");
		} else {
		    System.out.print("|");
		}

		// Stop coloring
		if ( _grid[y][x] == 0 || ( x == i && y == j ) ) {
		    System.out.print((char)27 + "[m");
		}
	    }
	    System.out.println("");
	}
    }

    // Define maze-carving algorithm 
    private void carvePassageFrom(int x,int y) {
	// construct and shuffle the directions array 
	int[] directions = new int[4];
	directions[0] = Maze.N;
	directions[1] = Maze.S;
	directions[2] = Maze.E;
	directions[3] = Maze.W;
	shuffle(directions);

	for ( int i=0; i < 4; ++i ) {
	    // 
	    // Render updates of the maze on a "cell-by-cell" basis
	    //
	    if ( _animate ) {
		display(x,y);
		try {
		    Thread.sleep((long)(_delay*1000));
		} catch ( Exception ex ) {
		    ex.printStackTrace();
		}
	    }
	    
	    int direction = directions[i];
	    int dx = x + Maze.DX(direction);
	    int dy = y + Maze.DY(direction);
	    if ( ( dy >= 0 && dy <= (_h-1) ) &&
		 ( dx >= 0 && dx <= (_w-1) ) &&
		 ( _grid[dy][dx] == 0 ) ) {
		_grid[y][x] |= direction;
		_grid[dy][dx] |= Maze.OPPOSITE(direction);
		carvePassageFrom(dx,dy);
	    }
	}

	//
	// Make one final call to "update" to display last cell.
	// Set the coords to (-1,-1) so the cell is left "blank" with no cursor.
	//
	if ( _animate ) {
	    display(-1,-1);
	}
    }
	
    // randomly shuffle the _directions array
    private void shuffle(int[] args) {
	for ( int i=0; i < args.length; ++i ) {
	    int pos = _random.nextInt(args.length);
	    int tmp = args[i];
	    args[i] = args[pos];
	    args[pos] = tmp;
	}
    }
}