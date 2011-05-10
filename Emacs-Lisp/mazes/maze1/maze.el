#!/usr/bin/emacs --script

;;
;; Out of the box, Emacs Lisp does not support objects.
;; The examples in this branch therefore implement 
;; the maze algorithm in a "procedural" way, that is, 
;; without the use of formal "objects" in the OO sense.
;;
;; See the Emacs-Lisp+CLOS branch for Lisp examples 
;; that incorporate CLOS object services.
;;

;; set GLOBAL constants
(setq N 1)
(setq S 2)
(setq E 4) 
(setq W 8)

(defun DX (d)
  (cond ((= d N) 0)
	((= d S) 0)
	((= d E) 1)
	((= d W) -1)))

(defun DY (d)
  (cond ((= d N) -1)
	((= d S) 1)
	((= d E) 0)
	((= d W) 0)))

(defun OPPOSITE (d)
  (cond ((= d N) S)
	((= d S) N)
	((= d E) W)
	((= d W) E)))
	
(defun initialize_maze ()
  (defun initialize_maze_iter (n g)
    (if (= n (* width height))
	g
      (initialize_maze_iter (+ n 1) (append g (list 0)))))
  (initialize_maze_iter 0 '()))
	
;;
;; Draw top row of the maze.
;; Make is "n" units wide.
;;
(defun draw_maze_top_row (n)
  (cond ((= n 0) (princ "\n"))
	(t
	 (princ "_")
	 (draw_maze_top_row (- n 1)))))

(defun draw_maze_row (i)
  (defun draw_maze_row_iter (cell)
    (cond ((= cell width) (princ "x\n"))
	  (t
	   (princ "y")
	   (draw_maze_row_iter (+ cell 1)))))
  (draw_maze_row_iter 0))


(defun draw_maze_grid ()
  (defun draw_maze_grid_iter (n)
    (cond ((< n height)
	   (draw_maze_row n)
	   (draw_maze_grid_iter (+ n 1)))))
  (draw_maze_grid_iter 0))

;;
;; Output the metadata about the maze.
;;
(defun draw_maze_metadata ()
  (princ
   (concat (number-to-string width) " "
	   (number-to-string height) " "
	   "\n")))

;;
;; Draw the maze itself.
;;
(defun draw_maze ()
  (draw_maze_top_row (- (* 2 width) 1))
  (draw_maze_grid)
  (draw_maze_metadata))

;;
;; Configure user-supplied instance variables
;;
(setq width 10)
(setq height 10)
(setq grid (initialize_maze))

;;
;; Draw the maze itself.
;;
(draw_maze)
