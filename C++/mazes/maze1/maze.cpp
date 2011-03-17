#include <iostream>
#include "maze.h"
#include "optparse.h" 	// custom library defined by psholtz for parsing command line args

using namespace std; 

map<int,int> Maze::DX = Maze::create_map_dx();
map<int,int> Maze::DY = Maze::create_map_dy();
map<int,int> Maze::OPPOSITE = Maze::create_map_opposite();

// =====================================
// Constructors
//
// @Parameter: w - width of the maze;
// @Parameter: h - height of the maze;
// @Parameter: s - used to seed PRNG (use "constant" value for deterministic behavior)
// =====================================
Maze::Maze(int w, int h, int s)
{
	_width = w;
	_height = h;
	_seed = s;

	srand(_seed);

	_grid = (int*)malloc( sizeof(int) * _width * _height );
	for ( int i=0; i < _width * _height; ++i ) 
		_grid[i] = 0;
}

// ===========
// Destructor
// ===========
Maze::~Maze()
{
	delete[] _grid;
}

// =========================
// Render the maze in ASCII
// =========================
void
Maze::draw()
{
	// Draw the "top" line.
	cout << " ";
	for ( int i=0; i < 2 * _width - 1; ++i ) 
		cout << "_";
	cout << endl;

	// Fill in the grid.
	int val;
	for ( int j=0; j < _height; ++j ) {
		cout << "|";
		for ( int i=0; i < _width; ++i ) {
			val = _grid[index(i,j)];
			if ( (val&S) != 0 )
				cout << " ";
			else
				cout << "_";

			if ( (val&E) != 0 ) 
				if ( ((val | _grid[index(i+1,j)]) & S) != 0 )
					cout << " ";
				else
					cout << "_";
			else
				cout << "|";
		}
		cout << endl;
	}

	// Output maze metadata.
	cout << " width: " << _width << ", height: " << _height << ", seed: " << _seed << endl;
}

// ===========================================================
// Take the (x,y) coordinates for the maze entry,
// and return the corresponding index into the _grid array.
//
// @Parameter: x - x-coordinate of grid entry;
// @Parameter: y - y-coordinate of grid entry;
// @Paramter: int - corresponding index into _grid array;
// ===========================================================
int 
Maze::index(int x, int y)
{
	return y * _height + x;
}

int 
main(int argc, char* argv[])
{
	OptParser o(argc,argv);
	o.prepare_to_start_attributes();
	o.add_integer_attribute("w","width","(optional)",DEFAULT_WIDTH);
	o.add_integer_attribute("h","height","(optional)",DEFAULT_HEIGHT);
	o.add_integer_attribute("s","seed","(optional)",DEFAULT_SEED);
	o.prepare_to_end_attributes();

	if ( o.parse() ) {
		Maze m(o.get_integer_attribute("w"),
			o.get_integer_attribute("h"),
			o.get_integer_attribute("s"));
		m.draw();
	} else {
		o.usage();
	}

	return 0;
}
