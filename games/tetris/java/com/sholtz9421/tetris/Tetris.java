package com.sholtz9421.tetris;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.BevelBorder;

public class Tetris extends JFrame {
	
	enum GameState {
		Score, Paused, GameOver
	};
	
	/**
	 * Update the game state label. 
	 * 
	 * @param state
	 * @param score
	 */
	public void setGameState(GameState state, int score) {
		switch ( state ) {
		case Score:
			statusbar.setText("Score: " + score);
			break;
		case Paused:
			statusbar.setText("Paused");
			break;
		case GameOver:
			statusbar.setText("Game Over!");
			break; 
		}
	}
	
	// control panel 
	private JPanel control;
	private JLabel statusbar; 
	
	// tetris board itself 
	private Board board;
	
	/**
	 * Construct a new game. 
	 */
	public Tetris() {
		super();
		initUI();
	}
	
	/**
	 * Configure the user interface. 
	 */
	protected void initUI() {
		// configure the control bar 
		control = new JPanel();
		statusbar = new JLabel();
		statusbar.setFont(new Font("SansSerif", Font.PLAIN, 12));
		control.add(statusbar,BorderLayout.CENTER);
		control.setBorder(BorderFactory.createBevelBorder(BevelBorder.LOWERED));
		control.setBackground(Color.WHITE);
		add(control,BorderLayout.SOUTH);
		
		// configure the current score
		setGameState(GameState.Score,0);
		
		// add the tetris board 
		board = new Board(this); 
		add(board);
		
		// frame basics
		setTitle("Tetris");
		setSize(200,400);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLocationRelativeTo(null);
		setResizable(false);
	}
	
	public JLabel getStatusBar() { return statusbar; }
	
	/**
	 * Static run loop.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				Tetris t = new Tetris();
				t.setVisible(true);
			}
		});
	}
}
