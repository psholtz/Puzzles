import java.util.ArrayList;
import java.util.List;
import java.util.Stack;


/****************************************************************************
 * Generate a maze using randomized variant of Kruskal's algorithm.
 * 
 * Loosely speaking, the algorithm is implemented as follows:
 * 
 * (1) Designate the "walls" between cells as edges.
 * (2) Randomly selected an edge.
 * (3) If the selected edge connects two disjoint trees, join the trees.
 * (4) Otherwise, throw that edge away.
 * (5) Repeat at Step 2.
 * 
 * @author psholtz
 ****************************************************************************/
public class Kruskal extends Maze {
	// Define instance variables
	private boolean _animate = false;
	private float _delay = 0.0f;
	
	private List<List<Tree>> _sets;
	private Stack<Edge> _edges;
	
	//
	// Standard Constructors
	//
	public Kruskal() {
		super();
		initialize();
	}
	public Kruskal(int w,int h) {
		super(w,h);
		initialize();
	}
	public Kruskal(int w,int h,long seed) {
		super(w,h,seed);
		initialize(); 
	}

	// 
	// Animating Constructor(s)
	//
	public Kruskal(int w,int h,boolean animate,float delay) {
		super(w,h);
		_animate = animate;
		_delay = delay;
		initialize();
	}

	public Kruskal(int w,int h,boolean animate,float delay,long seed) {
		super(w,h,seed);
		_animate = animate;
		_delay = delay;
		initialize();
	}
	
	private void initialize() {
		
		// Initialize the sets to the same dimension as the maze.
		// We use Tree objects to represent the sets to be joined. 
		_sets = new ArrayList<List<Tree>>();
		for ( int y=0; y < _h; ++y ) {
			List<Tree> tmp = new ArrayList<Tree>();
			for ( int x=0; x < _w; ++x ) {
				tmp.add(new Tree());
			}
			_sets.add(tmp);
		}
		
		// Build the collection of edges and randomize. 
		// Edges are "north" and "west" sides of cell, 
		// if index is greater than 0.
		_edges = new Stack<Edge>();
		for ( int y=0; y < _h; ++y ) {
			for (int x=0; x < _w; ++x ) {
				if ( y > 0 ) 	{ _edges.add(new Edge(x,y,Maze.N)); }
				if ( x > 0 ) 	{ _edges.add(new Edge(x,y,Maze.W)); }
			}
		}
		shuffle(_edges);
		
		if ( !_animate ) {
			carvePassages();
		}
	}
	
	/*******************************************************************
	 * Method only need to be overridden if we are animating.
	 * 
	 * If we are drawing the maze statically, defer to the superclass. 
	 ******************************************************************/
	public void draw() {
		// Clear the screen
		System.out.print((char)27 + "[2J");
		
		if ( !_animate ) {
			// Move to the upper left and defer to superclass.
			System.out.print((char)27 + "[H");
			super.draw();
		} else {
			// Carve the passages and animate as we go 
			carvePassages();
		}
	}
	
	/*****************************************************************
	 * Very similar, in terms of implementation, to the draw() 
	 * method in the superclass, the main difference being that
	 * here we will color a cell gray if it remains unconnected.
	 *****************************************************************/
	public void display() {
		// Draw the "top row" of the maze
		System.out.print((char)27 + "[H");
		System.out.print(" ");
		for ( int i=0; i < (_w*2) - 1; ++i ) {
			System.out.print("_");
		}
		System.out.println("");
		
		// Step through the grid/maze, cell-by-cell
		for ( int y=0; y < _grid.length; ++y ) {
			System.out.print("|");
			for ( int x=0; x < _grid[0].length; ++x ) {
				// Start coloring, if unconnected
				if ( _grid[y][x] == 0 ) 	{ System.out.print((char)27 + "[47m"); }
				
				System.out.print( ((_grid[y][x] & Maze.S) != 0) ? " " : "_" );
				if ( (_grid[y][x] & Maze.E) != 0 ) {
					System.out.print( (((_grid[y][x] | _grid[y][x+1]) & Maze.S) != 0) ? " " : "_" );
				} else {
					System.out.print("|");
				}
				
				// Stop coloring, if unconnected
				if ( _grid[y][x] == 0 ) 	{ System.out.print((char)27 + "[m"); }
			}
			System.out.println("");
		}
	}
	
	/*************************************************
	 * Implement Kruskal's algorithm.
	 * 
	 * (1) Randomly select an edge.
	 * (2) If the sets are not already connected, then
	 * (3) Connect the sets, and 
	 * (4) Knock down the wall between the sets.
	 * (5) Repeat at Step 1.
	 *************************************************/
	private void carvePassages() {
		while ( _edges.size() > 0 ) {
			// Select the next edge, and decide which direction we are going in.
			Edge tmp = _edges.pop();
			int x = tmp.getX();
			int y = tmp.getY();
			int direction = tmp.getDirection();
			int dx = x + Maze.DX(direction), dy = y + Maze.DY(direction);
			
			// Pluck out the corresponding sets
			Tree set1 = (_sets.get(y)).get(x);
			Tree set2 = (_sets.get(dy)).get(dx);
			
			if ( !set1.connected(set2) ) {
				// If we are animating, display the maze and pause
				if ( _animate ) {
					display();
					try {
						 Thread.sleep((long)(_delay * 1000));
					} catch ( Exception ex ) {
						ex.printStackTrace();
					}
				}
				
				// Connect the two sets and "knock down" the wall between them.
				set1.connect(set2);
				_grid[y][x] |= direction;
				_grid[dy][dx] |= Maze.OPPOSITE(direction);
			}
		}
		
		if ( _animate ) {
			// Display the final iteration
			display();
			
			// Output maze metadata
			outputMetadata(); 
		}
	}
	
	/**
	 * Randomly shuffle a List. 
	 * 
	 * @param args List (of Edges) to be randomly shuffled.
	 */
	private void shuffle(List<Edge> args) {
		for ( int i=0; i < args.size(); ++i ) {
			int pos = _random.nextInt(args.size());
			Edge tmp1 = args.get(i);
			Edge tmp2 = args.get(pos);
			args.set(i,tmp2);
			args.set(pos,tmp1);
		}
	}
}

/***********************************************************************
 * We will use a tree structure to model the "set" (or "vertex") 
 * that is used in Kruskal to build the graph.
 * 
 * @author psholtz
 ***********************************************************************/
class Tree {
	
	private Tree _parent = null;
	
	//
	// Build a new tree object
	//
	public Tree() {
		
	}
	
	// 
	// If we are joined, return the root. Otherwise, return this object instance.
	//
	public Tree root() {
		return _parent != null ? _parent.root() : this;
	}
	
	// 
	// Are we connected to this tree?
	//
	public boolean connected(Tree tree) {
		return this.root() == tree.root();
	}
	
	//
	// Connect to the tree
	//
	public void connect(Tree tree) {
		tree.root().setParent(this);
	}
	
	//
	// Set the parent of the object instance
	public void setParent(Tree parent) {
		this._parent = parent;
	}
}

/*********************************************************************************************
 * Encapsulates the x,y coord of where the edge starts, and the direction in which it points.
 * 
 * @author psholtz
 *********************************************************************************************/
class Edge {
	private int _x;
	private int _y;
	private int _direction;
	
	public Edge(int x, int y, int direction) {
		_x = x; 
		_y = y;
		_direction = direction;
	}
	
	public int getX() { return _x; }
	public int getY() { return _y; }
	public int getDirection() { return _direction; }
}