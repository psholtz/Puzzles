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
	
;; set instance variables
(setq width 10)
(setq height 10)

;;
;; Draw top row of the maze.
;; Make is "n" units wide.
;;
(defun draw_maze_top_row (n)
  (cond ((= n 0) (princ "\n"))
	(t
	 (princ "_")
	 (draw_maze_top_row (- n 1)))))

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
  (draw_maze_metadata))

(draw_maze)
