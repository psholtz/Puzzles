/*******************************************************************
 * Implement extremely simple "optparse" algortihm for java.
 * 
 * Only programmed to recognize the few switches we are using, and 
 * then only in the "short" form of optparse.
 * 
 * @author psholtz
 ******************************************************************/
public class Driver {
	public static void main(String[] args) {
		// configure the width and height
		int w = Maze.DEFAULT_WIDTH;
		int h = Maze.DEFAULT_HEIGHT;
		long seed = 0L; 
		boolean useSeed = false;
		
		// ignore arguments that we don't understand
		for ( int i=0; i < args.length; ++i ) {
			String arg = args[i];
			if ( arg.length() > 2 ) {
				String s = arg.substring(0,1);
				String t = arg.substring(1,2);
				if ( s.equals("-")) { 
					if ( t.equals("w") ) {
						w = Integer.parseInt(arg.substring(2));
					}
					else if ( t.equals("h") ) {
						h = Integer.parseInt(arg.substring(2));
					}
					else if ( t.equals("s") ) {
						useSeed = true; 
						seed = Long.parseLong(arg.substring(2));
					}
				}
			}
		}
		
		// render the maze
		if ( useSeed ) {
			new BackTracker(w,h,seed).draw();
		} else {
			new BackTracker(w,h).draw();
		}
	}
}