package com.sholtz9421.tetris;

import java.util.Random;

public class Shape {
	
	/**
	 * Enumeration of the various Tetris "shapes" that we can use in our game.
	 */
	enum Tetroids {
		NoShape, ZShape, SShape, LineShape, 
		TShape, SquareShape, LShape, MirroredLShape
	};
	
	/**
	 * Physical coordinates corresponding to the shapes listed above. 
	 */
	private static int coordsTable[][][] = new int[][][] {
		{ { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },	   // NoShape
		{ { 0, -1 }, { 0, 0 }, { -1, 0 }, { -1, 1 } }, // ZShape
		{ { 0, -1 }, { 0, 0 }, { 1, 0 }, { 1, 1 } },   // SShape
		{ { 0, -1 }, { 0, 0 }, { 0, 1 }, { 0, 2 } },   // LineShape
		{ { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 } },   // TShape
		{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } },    // SquareShape
		{ { -1, -1 }, { 0, -1 }, { 0, 0 }, { 0, 1 } }, // LShape 
		{ { 1, -1 },  { 0, -1 }, { 0, 0 }, { 0, 1 } }  // MirroredLShape
	};
	
	private Tetroids pieceShape;
	private int coords[][];

	/***
	 * Construct a new shape.
	 */
	public Shape() {
		coords = new int[4][2];
		setShape(Tetroids.NoShape);
	}
	
	/**
	 * Configure this shape with the argument Tetroids shape. 
	 * 
	 * @param shape
	 */
	public void setShape(Tetroids shape) {
		for ( int i=0; i < 4; ++i ) {
			for ( int j=0; j < 2; ++j ) {
				coords[i][j] = coordsTable[shape.ordinal()][i][j];
			}
		}
		
		pieceShape = shape; 
	}
	
	//
	// Set x and y variables
	//
	private void setX(int index, int x) { coords[index][0] = x; }
	private void setY(int index, int y) { coords[index][1] = y; }
	
	//
	// Get x and y variables
	//
	public int x(int index) { return coords[index][0]; }
	public int y(int index) { return coords[index][1]; }
	
	// 
	// Get the current shape
	//
	public Tetroids getShape() { return pieceShape; }
	
	/***
	 * Select a new random shape. 
	 */
	public void setRandomShape() {
		Random r = new Random();
		int x = Math.abs(r.nextInt()) % 7 + 1;
		Tetroids[] values = Tetroids.values();
		setShape(values[x]);
	}
	
	/**
	 * Find minimum x.
	 * 
	 * @return
	 */
	public int minX() {
		int m = coords[0][0];
		for ( int i=0; i < 4; ++i ) {
			m = Math.min(m, coords[i][0]);
		}
		return m;
	}
	
	/**
	 * Find minimum y. 
	 * 
	 * @return
	 */
	public int minY() {
		int m = coords[0][1];
		for ( int i=0; i < 4; ++i ) {
			m = Math.min(m, coords[i][1]);
		}
		return m; 
	}
	
	/**
	 * Rotate shape to the left.
	 * 
	 * @return
	 */
	public Shape rotateLeft() {
		if ( pieceShape == Tetroids.SquareShape ) {
			return this;
		}
		
		Shape result = new Shape();
		result.pieceShape = pieceShape;
		
		for ( int i=0; i < 4; ++i ) {
			result.setX(i, y(i));
			result.setY(i, -x(i));
		}
		
		return result; 
	}
	
	/**
	 * Rotate shape to the right.
	 * 
	 * @return
	 */
	public Shape rotateRight() {
		if ( pieceShape == Tetroids.SquareShape ) {
			return this;
		}
		
		Shape result = new Shape();
		result.pieceShape = pieceShape;
		
		for ( int i=0; i < 4; ++i ) {
			result.setX(i, -y(i));
			result.setY(i, x(i));
		}
		
		return result; 
	}
}
