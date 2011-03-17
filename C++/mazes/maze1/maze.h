/*****************************************************************************
 * Implements a simple back-tacking algorithm for drawing simple ASCII mazes.
 * 
 * Maze is a class that define basic behavior that mazes must conform to.
 * 
 * Subclass BackTracker implements the actual back-tracking algorithm.
 *****************************************************************************/
#include <time.h>
#include <map>

#define DEFAULT_WIDTH 10
#define DEFAULT_HEIGHT 10
#define DEFAULT_SEED time(NULL)

#define N 1
#define S 2
#define E 4
#define W 8

class Maze 
{
public:
	//
	// Constructors
	//
	Maze(int w=DEFAULT_WIDTH, int h=DEFAULT_HEIGHT, int s=DEFAULT_SEED);
	virtual ~Maze();

	void draw();

	static std::map<int,int> DX;
	static std::map<int,int> DY;
	static std::map<int,int> OPPOSITE;

	static std::map<int,int> create_map_dx()
	{
		std::map<int,int> m;
		m[N] = 0;
		m[S] = 0;
		m[E] = +1;
		m[W] = -1;
		return m;
	}

	static std::map<int,int> create_map_dy()
	{
		std::map<int,int> m;
		m[N] = -1;
		m[S] = +1;
		m[E] = 0;
		m[W] = 0;
		return m;
	}
	
	static std::map<int,int> create_map_opposite()
	{
		std::map<int,int> m;
		m[N] = S;
		m[S] = N;
		m[E] = W;
		m[W] = E;
		return m;
	}	

protected:
	int _width;	// width of the maze
	int _height;	// height of the maze
	int _seed;	// seed to use for PRNG
	int *_grid;	// actual grid of values in maze

	int index(int x, int y);			// find the array index for point (x,y)
};

class BackTracker : public Maze
{
public:
	//
	// Constructors
	//
	BackTracker(int w=DEFAULT_WIDTH, int h=DEFAULT_HEIGHT, int s=DEFAULT_SEED);
	virtual ~BackTracker();

protected:
	void create_passage_from(int x, int y);		// carve a passage starting at (x,y)
};
