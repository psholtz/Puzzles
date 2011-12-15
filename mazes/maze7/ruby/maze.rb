#!/usr/bin/ruby

width = (ARGV[0] || 10).to_i
height = (ARGV[1] || width).to_i
seed = (ARGV[2] || rand(0xFFFF_FFFF)).to_i

srand(seed)

grid = Array.new(height) { Array.new(width,0) }

S,E = 1,2
HORIZONTAL,VERTICAL = 1,2

def display_maze(grid)
    print "\e[H"
    puts " " + "_"*(grid[0].length * 2 - 1)
    grid.each_with_index do |row,y|
      print "|"
      row.each_with_index do |cell,x|
        bottom = y + 1 > grid.length
	south = (cell & S != 0 || bottom)
	south2 = (x+1 < grid[y].length && grid[y][x+1] & S != 0 || bottom)
	east = (cell & E != 0 || x +1 > grid[y].length)

	print(south ? "_" : " ")
	print(east ? "|" : ((south && south2) ? "_" : " "))        
      end
      puts
    end
end

def choose_orientation(width,height)
    if width < height
       HORIZONTAL
    elsif height < width
    	  VERTICAL
    else
	rand(2) == 0 ? HORIZONTAL : VERTICAL
    end
end

def divide(grid,x,y,width,height,orientation)
    return if width < 2 || height < 2
    display_maze(grid)
    sleep 0.02

    horizontal = orientation == HORIZONTAL

    wx = x + (horizontal ? 0 : rand(width-2))
    wy = y + (horizontal ? rand(height-2) : 0)
    
    px = wx + (horizontal ? rand(width) : 0)
    py = wy + (horizontal ? 0 : rand(height))

    dx = horizontal ? 1 : 0
    dy = horizontal ? 0 : 1

    length = horizontal ? width : height

    dir = horizontal ? S : E

    length.times do
      grid[wy][wx] |= dir if wx != px || wy != py
      wx += dx
      wy += dy
    end

    nx,ny = x,y
    w, h = horizontal ? [width,wy-y+1] : [wx-x+1, height]
    divide(grid,nx,ny,w,h,choose_orientation(w,h))

    nx,ny = horizontal ? [x,wy+1] : [wx+1,y]
    w,h = horizontal ? [width, y+height-wy-1] : [x+width-wx-1,height]
    divide(grid,nx,ny,w,h,choose_orientation(w,h))
end

print "\e[2J"
divide(grid,0,0,width,height,choose_orientation(width,height))
display_maze(grid)

puts "#{$0} #{width} #{height} #{seed}"