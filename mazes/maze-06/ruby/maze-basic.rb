#!/usr/bin/ruby

require 'optparse'

width = (ARGV[0] || 10).to_i
height = (ARGV[1] || "-") == "-" ? nil : ARGV[1].to_i
seed = (ARGV[2] || rand(0xFFFF_FFFF)).to_i

srand(seed)

S,E = 1,2

class State

 attr_reader :width

 def initialize(width,next_set=-1)
  @width = width
  @next_set = next_set
  @sets = Hash.new { |h,k| h[k] = [] }
  @cells = {}
 end

 def next
  State.new(width,@next_set)
 end 

 def populate
  width.times do |cell|
   unless @cells[cell]
    set = @next_set += 1
    @sets[set] << cell
    @cells[cell] = set
   end
  end
  self
 end 

 def merge(sink_cell, target_cell)
  sink,target = @cells[sink_cell], @cells[target_cell]

  @sets[sink].concat(@sets[target])
  @sets[target].each { |cell| @cells[cell] = sink }
  @sets.delete(target)
 end

 def same?(cell1, cell2)
  @cells[cell1] == @cells[cell2]
 end

 def add(cell, set)
  @cells[cell] = set
  @sets[set] << cell
  self
 end

 def each_set
  @sets.each do |id,set|
   yield id, set
  end
 end
end

def row2str(row, last=false)
 s = "\r|"
 row.each_with_index do |cell, index|
  south = (cell & S != 0)
  next_south = (row[index+1] && row[index+1] & S != 0)
  east = (cell & E != 0)

  s << (south ? " " : "_")

  if east
   s << ((south || next_south) ? " " : "_")
  else
   s << "|"
  end
 end
 return s
end

state = State.new(width).populate
row_count = 0

def step(state, finish=false)
 connected_sets = []
 connected_set = [0]

 (state.width-1).times do |c|
  if state.same?(c,c+1) || (!finish && rand(2) > 0)
   connected_sets << connected_set
   connected_set = [c+1]
  else 
   state.merge(c,c+1)
   connected_set << c+1
  end
 end
 connected_sets << connected_set

 verticals = []
 next_state = state.next

 unless finish
  state.each_set do |id,set|
   cells_to_connect = set.sort_by { rand } [0,1+rand(set.length-1)]
   verticals.concat(cells_to_connect)
   cells_to_connect.each { |cell| next_state.add(cell,id) }
  end
 end

 row = []
 connected_sets.each do |connected_set| 
  connected_set.each_with_index do |cell,index|
   last = (index+1 == connected_set.length)
   map = last ? 0 : E
   map |= S if verticals.include?(cell)
   row << map
  end
 end
 [next_state.populate,row]
end

spinning = true
trap("INT") { spinning = false }

puts " " + "_" * (width*2 - 1)

while spinning
 state,row = step(state)
 row_count == 1
 puts row2str(row)
 spinning = row_count + 1 < height if height
end

state, row = step(state,true)
row_count += 1

puts row2str(row)

puts "#{$0} #{width} #{row_count} #{seed}"