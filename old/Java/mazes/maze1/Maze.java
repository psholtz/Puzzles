
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * Class Maze defines basic behavior to which a maze should conform.
 * It provides basic initialization/construction for the maze class, 
 * and provides a method for drawing ASCII mazes.
 * 
 * Specific "maze-carving" techniques are implemented in subclasses.
 * 
 * @author psholtz
 *
 */
public class Maze {

	// Define the "DEFAULT" variable values
	public static int DEFAULT_WIDTH = 10;
	public static int DEFAULT_HEIGHT = 10;
	public static int DEFAULT_SEED = 10;
	
	// ++++++++++++++++++++++++++++++
	// Configure the class variables
	// ++++++++++++++++++++++++++++++ 
	public static int N = 1;
	public static int S = 2;
	public static int E = 4;
	public static int W = 8;
	
	public static final Map<Integer,Integer> DX =
		Collections.unmodifiableMap(new HashMap<Integer,Integer>() {{
			put(E,+1);
			put(W,-1);
			put(N,0);
			put(S,0);
		}});
	
	public static final Map<Integer,Integer> DY =
		Collections.unmodifiableMap(new HashMap<Integer,Integer>() {{
			put(E,0);
			put(W,0);
			put(N,-1);
			put(S,+1);
		}});
	
	public static final Map<Integer,Integer> OPPOSITE = 
		Collections.unmodifiableMap(new HashMap<Integer,Integer>() {{
			put(E,W);
			put(W,E);
			put(N,S);
			put(S,N);
		}});
	
	// +++++++++++++++++++++++++++++++++ 
	// References to instance variables
	// +++++++++++++++++++++++++++++++++ 
	public int width;
	public int height;
	public int seed;
	
	protected int grid[][]; 
	
	/**
	 * Initialize a new 2D maze with the given width and height.
	 * 
	 * Default seed value will give "random" behavior.
	 * User-supplied seed value will give "deterministic" behavior.
	 * 
	 * @param w Width of the maze.
	 * @param h Height of the maze.
	 * @param s Seed for the PRNG. 
	 */
	public Maze(int w, int h, int s) {
		width = w;
		height = h;
		seed = s;
		
		grid = new int[height][width];
	}
	
	/**
	 * Mimic default arguments by overloading constructor.
	 * 
	 * @param w Width of the maze.
	 * @param h Height of the maze.
	 */
	public Maze(int w, int h) { this(w,h,DEFAULT_SEED); }
	
	/**
	 * Mimic default arguments by overloading constructor.
	 * 
	 * @param w Width of maze.
	 */
	public Maze(int w) { this(w,DEFAULT_HEIGHT,DEFAULT_SEED); }
	
	/**
	 * Mimic default arguments by overloading constructor. 
	 */
	public Maze() { this(DEFAULT_WIDTH,DEFAULT_HEIGHT,DEFAULT_SEED); }
	
	/**
	 * Draw the grid, starting in the upper-left hand corner. 
	 */
	public void draw() {
		//
		// Draw the "top" line
		//
		WriteBuffer buffer = new WriteBuffer();
		buffer.add(" ");
		for ( int i=0; i < 2*width-1; ++i ) {
			buffer.add("_");
		}
		buffer.flush();
		
		//
		// Draw each of the rows.
		//
		for ( int j=0; j < height; ++j ) {
			buffer.add("|");			
			for ( int i=0; i < width; ++i ) {
				// render the "bottom" using the S switch
				buffer.add( (grid[j][i] & S) != 0 ? " " : "_" );
				
				// render the "side" using the E switch
				if ( (grid[j][i] & E) != 0 ) {
					buffer.add( ( (grid[j][i] | grid[j][i+1]) & S ) != 0 ? " " : "_" );
				} else {
					buffer.add("|");
				}
			}
			buffer.flush();
		}
		
		//
		// Output maze metadata.
		// 
		buffer.add(width + " " + height + " " + seed);
		buffer.flush();
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Maze m = new BackTracker();
		m.draw(); 
	}

}

class BackTracker extends Maze {
	public BackTracker() {
		//
		// Invoke super-constructor
		//
		super();
		
		// 
		// Carve the grid
		//
		carve_passage_from(0,0);
	}
	
	/**
	 * Recursively carve passages through the maze, starting at (x,y).
	 * 
	 * Algorithm halts when all "cells" in the maze have been visited. 
	 * 
	 * @param x X-point on grid, where to begin carving.
	 * @param y Y-point on grid, where to begin carving. 
	 */
	public void carve_passage_from(int x,int y) {
		int direction, dx, dy;
		int directions[] = { N, S, E, W };
		Collections.shuffle(Arrays.asList(directions));
		for ( int i=0; i<directions.length; ++i ) {
			direction = directions[i];
			dx = x + DX.get(direction); 
			dy = y + DY.get(direction);
			if ( dy >= 0 && dy < height && dx >= 0 && dx < width && grid[dy][dx] == 0) {
				grid[y][x] |= direction;
				grid[dy][dx] |= OPPOSITE.get(direction);
				carve_passage_from(dx,dy);
 			}
		}		
	}
}

class WriteBuffer {
	
	protected ArrayList<String> buffer;
	public WriteBuffer() {
		buffer = new ArrayList<String>();
	}
	
	public void add(String s) {
		buffer.add(s);
	}
	
	public String join(String link) {
		String cache = "";
		for ( String s : buffer ) {
			cache += s + link;
		}
		return cache;
	}
	
	public void clear() {
		buffer.clear();
	}
	
	public void flush() {
		System.out.println(join(""));
		clear();
	}
	public void flush(String link){
		System.out.println(join(link));
		clear();
	}
}