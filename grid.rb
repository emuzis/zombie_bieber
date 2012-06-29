class Grid
  N, S, E, W = 1, 2, 4, 8
  DX         = { E => 1, W => -1, N =>  0, S => 0 }
  DY         = { E => 0, W =>  0, N => -1, S => 1 }
  OPPOSITE   = { E => W, W =>  E, N =>  S, S => N }
  
  attr_accessor :grid_hash
  
  def initialize(height, width)
    @height = height
    @width  = width
    @seed = srand(rand(0xFFFF_FFFF))
    
    @grid = Array.new(height) { Array.new(width, 0) }
    carve_passages_from(0, 0)
    
    @grid_hash = get_maze
  end
  
  def carve_passages_from(cx, cy)
    directions = [N, S, E, W].sort_by{rand}

    directions.each do |direction|
      nx, ny = cx + DX[direction], cy + DY[direction]

      if ny.between?(0, @grid.length-1) && nx.between?(0, @grid[ny].length-1) && @grid[ny][nx] == 0
        @grid[cy][cx] |= direction
        @grid[ny][nx] |= OPPOSITE[direction]
        carve_passages_from(nx, ny)
      end
    end
  end
  
  def get_maze
    return_map = Array.new(@grid.size) { |a| a = Array.new(@grid[0].size) {|a| a = Hash.new} }
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return_map[y][x][:top]     = ((cell & N) == 0) ? true : false
        return_map[y][x][:bottom]  = ((cell & S) == 0) ? true : false
        return_map[y][x][:left]    = ((cell & W) == 0) ? true : false
        return_map[y][x][:right]   = ((cell & E) == 0) ? true : false
      end
    end  
    return_map
  end
  
end