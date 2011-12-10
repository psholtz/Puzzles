Kruskal's Algorithm
===================

Kruskal's algorithm is a greedy algorithm that is able to find a minimum spanning tree for a connected weighted graph. With a few modifications, we can use a randomized version of this algorithm to generate some pretty slick ASCII mazes as well.

For the sake of simplicity, we will represent "sets" as a tree data structure, and "connect" graphs by adding subtrees to a root tree.

1. xx
2. xx
3. xx
4. xx
5. xx

The algorithm terminates when there are no more unconnected sets.

The algorithm is straightforward, but it tends to leave an abundance of short cul-de-sacs in the maze.

Sample Maze
----------- 

[![](http://farm8.staticflickr.com/7022/6484512617_eb2df1d1ca_m.jpg)](http://farm8.staticflickr.com/7022/6484512617_eb2df1d1ca_m.jpg)