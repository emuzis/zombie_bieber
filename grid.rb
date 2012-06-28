class Grid
  N, S, E, W = 1, 2, 4, 8
  DX         = { E => 1, W => -1, N =>  0, S => 0 }
  DY         = { E => 0, W =>  0, N => -1, S => 1 }
  OPPOSITE   = { E => W, W =>  E, N =>  S, S => N }
  
  attr_accessor :grid_hash
  
  def initialize(height, width)
    @height = height
    @width  = width
    
    @grid = Array.new(height) { Array.new(width, 0) }
    generate_grid
    
    @grid_hash = get_maze
  end
  
  def generate_grid
    @height.times do |y|
      @width.times do |x|
        dirs = []
        dirs << N if y > 0
        dirs << W if x > 0

        if (dir = dirs[rand(dirs.length)])
          nx, ny = x + DX[dir], y + DY[dir]
          @grid[y][x] |= dir
          @grid[ny][nx] |= OPPOSITE[dir]
        end
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