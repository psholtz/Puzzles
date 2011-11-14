/**
 * Implement the random back-tracking algorithm for drawing ASCII mazes.
 * 
 * @author psholtz
 *
 */
public class BackTracker extends Maze {
	/**
	 * Initialize a new 2D maze with the optional parameters.
	 * 
	 * Maze implements the recursive back-tracking algorithm. 
	 * 
	 * @author psholtz
	 */
	public BackTracker() {
		super();
		carvePassageFrom(0,0);
	}
	public BackTracker(int w,int h) {
		super(w,h);
		carvePassageFrom(0,0);
	}
	public BackTracker(int w,int h,long seed) {
		super(w,h,seed);
		carvePassageFrom(0,0);
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
