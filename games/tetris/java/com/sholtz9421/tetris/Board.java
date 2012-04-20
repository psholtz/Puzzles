package com.sholtz9421.tetris;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.swing.JPanel;
import javax.swing.Timer;

import com.sholtz9421.tetris.Shape.Tetroids;
import com.sholtz9421.tetris.Tetris.GameState;

public class Board extends JPanel implements ActionListener {

	// 
	//  Board dimensions
	// 
	public static final int BoardWidth = 10;
	public static final int BoardHeight = 22;
	
	//
	// Timer variables
	//
	private Timer timer;
	private int timerInterval = 400;   
	
	//
	// Game state  variables
	//
	private boolean isFallingFinished = false;
	private boolean isStarted = false;
	private boolean isPaused = false; 
	
	private int numLinesRemoved = 0;
	private int curX = 0;
	private int curY = 0; 
	
	private Tetris tetris;
	private Shape curPiece;
	private Tetroids[] board;
	
	private static final ScheduledExecutorService worker = Executors.newSingleThreadScheduledExecutor();
	private List<Integer> rowsToDelete = new ArrayList<Integer>();
	
	/**
	 * Construct a new tetris board. 
	 * 
	 * @param tetris
	 */
	public Board(Tetris tetris) {
		super();
		
		// save the tetris variable
		this.tetris = tetris;
		
		// configure the rest of the object
		setFocusable(true);
		curPiece = new Shape();
		timer = new Timer(timerInterval,this);
		board = new Tetroids[BoardWidth * BoardHeight];
		addKeyListener(new TetrisAdapter());
		
		// start the game ticking
		start(); 
	}
	
	/**
	 * "Tick" API invoked by the clock timer. 
	 */
	public void actionPerformed(ActionEvent evt) {
		if ( isFallingFinished ) {
			isFallingFinished = false;
			newPiece();
		} else {
			oneLineDown();
		}
	}
	
	// ============== 
	// GAME PLAY APIs
	// ==============
	private void start() {
		if ( isPaused ) { return; }
		
		isStarted = true;
		isFallingFinished = false;
		numLinesRemoved = 0;
		clearBoard(); 
		
		newPiece();
		timer.start(); 
	}
	
	/**
	 * Pause the game. 
	 */
	private void pause() {
		if ( !isStarted ) { return; }
		
		isPaused = !isPaused;
		if ( isPaused ) {
			timer.stop();
			tetris.setGameState(GameState.Paused, -1);
		} else {
			timer.start();
			tetris.setGameState(GameState.Score, numLinesRemoved);
		}
		repaint();
	}
	
	// =========== 
	// HELPER APIs
	// ===========
	public int squareWidth() { return (int)getSize().getWidth() / BoardWidth; }
	public int squareHeight() { return (int)getSize().getHeight() / BoardHeight; }
	
	// ===================== 
	// BOARD MANAGEMENT APIs
	// ===================== 
	private void clearBoard() {
		for ( int i=0; i < BoardHeight * BoardWidth; ++i ) {
			board[i] = Tetroids.NoShape;
		}
	}
	
	public Tetroids shapeAt(int x, int y) { return board[(y * BoardWidth) + x]; }
	
	// ===================== 
	// PIECE MANAGEMENT APIs
	// ===================== 
	private void newPiece() {
		curPiece.setRandomShape();
		curX = BoardWidth / 2 + 1;
		curY = BoardHeight - 1 + curPiece.minY();
		
		if ( !tryMove(curPiece, curX, curY) ) {
			curPiece.setShape(Tetroids.NoShape);
			timer.stop();
			isStarted = false;
			tetris.setGameState(GameState.GameOver, -1);
		}
	}
	
	/**
	 * Attempt to move the piece down by one line.
	 */
	private void oneLineDown() {
		if ( !tryMove(curPiece, curX, curY-1) ) {
			pieceDropped();
		}
	}
	
	/**
	 * Attempt to move the piece to a new position (i.e., newX and newY).
	 * 
	 * @param newPiece
	 * @param newX
	 * @param newY
	 * @return
	 */
	private boolean tryMove(Shape newPiece, int newX, int newY) {
		for ( int i=0; i < 4; ++i ) {
			int x = newX + newPiece.x(i);
			int y = newY - newPiece.y(i);
			if ( x < 0 || x >= BoardWidth || y < 0 || y >= BoardHeight ) {
				return false;
			} 
			if ( shapeAt(x,y) != Tetroids.NoShape ) {
				return false; 
			}
		}
		
		curPiece = newPiece;
		curX = newX;
		curY = newY;
		repaint();
		
		return true;
	}
	
	/**
	 * Invoked when the piece "falls" to the bottom row. 
	 */
	private void pieceDropped() {
		for ( int i=0; i < 4; ++i ) {
			int x = curX + curPiece.x(i);
			int y = curY - curPiece.y(i);
			board[(y * BoardWidth) + x] = curPiece.getShape();
		}
		
		removeFullLines();
		
		if ( !isFallingFinished ) {
			newPiece();
		}
	}
	
	/**
	 * Remove all the full lines on the board. 
	 */
	private void removeFullLines() {
		int numFullLines = 0;
		
		for ( int i = BoardHeight-1; i >= 0; --i ) {
			boolean isLineFull = true;
			for ( int j=0; j < BoardWidth; ++j ) {
				if ( shapeAt(j,i) == Tetroids.NoShape ) {
					isLineFull = false;
					break;
				}
			}
			
			if ( isLineFull ) {
				//
				// Increment the number of full lines
				// 
				++numFullLines;
				rowsToDelete.add(i);
				worker.schedule(new RowDeletionTask(i), timerInterval/2, TimeUnit.MILLISECONDS);
			}
		}
		
		//
		// Final step -- update the score
		// 
		if ( numFullLines > 0 ) {
			numLinesRemoved += numFullLines; 
			tetris.setGameState(GameState.Score, numLinesRemoved);
			isFallingFinished = true;
			curPiece.setShape(Tetroids.NoShape);
			repaint();
		}
	}
	
	/**
	 * Drop the piece down from its present location, to the bottom. 
	 */
	private void dropDown() {
		int newY = curY;
		while ( newY > 0 ) {
			if ( !tryMove(curPiece, curX, newY-1) ) {
				break;
			}
			--newY;
		}
		pieceDropped(); 
	}
	
	// ============= 
	// PAINTING APIs
	// ============= 
	public void paint(Graphics g) {
		super.paint(g);
		
		Dimension size = getSize();
		int boardTop = (int)size.getHeight() - BoardHeight * squareHeight();
		
		//
		// Draw existing pieces
		//
		for ( int i=0; i < BoardHeight; ++i ) {
			if ( rowsToDelete.contains(BoardHeight - i - 1) ) {
				for ( int j=0; j < BoardWidth; ++j ) { 
					drawSquareHighlight(g, j * squareWidth(), boardTop + i * squareHeight());
				}
			} else {
				for ( int j=0; j < BoardWidth; ++j ) {
					Tetroids shape = shapeAt(j, BoardHeight - i - 1);
					if ( shape != Tetroids.NoShape ) {
						drawSquare(g, j * squareWidth(), boardTop + i * squareHeight(), shape);
					}
				}
			}
		}
		
		//
		// Draw the current piece
		// 
		if ( curPiece.getShape() != Tetroids.NoShape ) {
			for ( int i=0; i < 4; ++i ) {
				int x = curX + curPiece.x(i);
				int y = curY - curPiece.y(i);
				drawSquare(g, 0 + x * squareWidth(), boardTop + (BoardHeight - y - 1) * squareHeight(), curPiece.getShape());
			}
		}
	}
	
	/**
	 * Draw a "highlighted" square, in the process of deleting the row.
	 * 
	 * @param g
	 * @param x
	 * @param y
	 */
	private void drawSquareHighlight(Graphics g, int x, int y) {
		Color color = Color.ORANGE;
		g.setColor(color);
		g.fillRect(x+1, y+1, squareWidth() - 2, squareHeight() - 2);
		
		g.setColor(color.brighter());
		g.drawLine(x, y + squareHeight()-1, x, y);
		g.drawLine(x, y, x + squareWidth()-1, y);
	
		g.setColor(color.darker());
		g.drawLine(x+1, y+squareHeight() - 1, x + squareWidth() - 1, y + squareHeight() - 1);
		g.drawLine(x + squareWidth() - 1, y + squareHeight() - 1, x + squareWidth() - 1, y+1);		
	}
	
	/**
	 * Draw a Tetroid square. 
	 * 
	 * @param g
	 * @param x
	 * @param y
	 * @param shape
	 */
	private void drawSquare(Graphics g, int x, int y, Tetroids shape) {
		Color colors[] = {
				new Color(0, 0, 0), new Color(204, 102, 102), 
	            new Color(102, 204, 102), new Color(102, 102, 204), 
	            new Color(204, 204, 102), new Color(204, 102, 204), 
	            new Color(102, 204, 204), new Color(218, 170, 0)
		};
		
		Color color = colors[shape.ordinal()];
		g.setColor(color);
		g.fillRect(x+1, y+1, squareWidth() - 2, squareHeight() -2);
		
		g.setColor(color.brighter());
		g.drawLine(x, y + squareHeight()-1,x,y);
		g.drawLine(x, y, x +squareWidth() - 1, y);
		
		g.setColor(color.darker());
		g.drawLine(x+1, y+squareHeight() - 1, x + squareWidth() - 1, y + squareHeight() - 1);
		g.drawLine(x + squareWidth() - 1, y + squareHeight() - 1, x + squareWidth() - 1, y+1);
	}
	
	// ================ 
	// KEYBOARD ADAPTER
	// ================ 
	class TetrisAdapter extends KeyAdapter {
		public void keyPressed(KeyEvent e) {
			//
			// Return if we are not doing anything
			//
			if ( !isStarted || curPiece.getShape() == Tetroids.NoShape ) {
				return;
			}
			
			//
			// Handle the pause call
			//
			int keyCode = e.getKeyCode();
			if ( keyCode == 'p' || keyCode == 'P' ) {
				pause();
				return;
			}
			if ( isPaused ) { return; }

			//
			// Handle the other calls
			// 
			switch ( keyCode) { 
			case KeyEvent.VK_LEFT:
				tryMove(curPiece, curX-1, curY);
				break;
				
			case KeyEvent.VK_RIGHT:
				tryMove(curPiece, curX+1, curY);
				break;
				
			case KeyEvent.VK_DOWN:
				tryMove(curPiece.rotateRight(), curX, curY);
				break;
				
			case KeyEvent.VK_UP:
				tryMove(curPiece.rotateLeft(), curX, curY);
				break;
				
			case KeyEvent.VK_SPACE:
				dropDown();
				break;
				
			case 'd':
			case 'D':
				oneLineDown();
				break;
			}
		}
	}
	
	/**
	 * Schedule the asynchronous deletion of "full" rows at row index i. 
	 */
	class RowDeletionTask implements Runnable {
		private int i;
		public RowDeletionTask(int i) {
			this.i = i;
		}
		public void run() {
			for ( int k=i; k < BoardHeight-1; ++k ) {
				for ( int j=0; j < BoardWidth; ++j ) {
					board[(k * BoardWidth) + j] = shapeAt(j,k+1);
				}
			}
			rowsToDelete.clear();
			repaint();
		}
	};
}
