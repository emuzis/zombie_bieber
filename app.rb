require 'grid'

img_height = 24
img_width = 24

border  = 1

row_num = 24
col_num = 24

margin = img_height / 2

app_height = (img_height + border * 2) * 24 + margin * 2
app_width = (img_height + border * 2) * 24 + margin * 2


wall_size = (2 * margin) + (border * 2)

cursor = { :x => margin + border, :y => margin + border }

top_left = { :x => margin, :y => margin }
top_right = { :x => app_height - margin, :y => margin }
bottom_right = { :x => app_height - margin, :y => app_width - margin }
bottom_left = { :x => margin, :y => app_width - margin }


grid = Grid.new(24,24).grid_hash

Shoes.app :height => app_height, :width => app_width do
  
  grid.each_with_index do |row, y|
    row.each_with_index do |box, x|
      if box[:top]
        line((top_left[:x] + x * wall_size), (top_left[:y] + y * wall_size), (top_left[:x] + (x + 1) * wall_size), (top_left[:y] + y * wall_size))
        line((top_left[:x] + x * wall_size), (top_left[:y] + y * wall_size)-1, (top_left[:x] + (x + 1) * wall_size), (top_left[:y] + y * wall_size)-1)
      end
      if box[:bottom]
        line((top_left[:x] + x * wall_size), (top_left[:y] + (y + 1) * wall_size), (top_left[:x] + (x + 1) * wall_size), (top_left[:y] + (y + 1) * wall_size))
        line((top_left[:x] + x * wall_size), (top_left[:y] + (y + 1) * wall_size)-1, (top_left[:x] + (x + 1) * wall_size), (top_left[:y] + (y + 1) * wall_size)-1)
      end
      if box[:left]
        line((top_left[:x] + x * wall_size), (top_left[:y] + y * wall_size), (top_left[:x] + (x) * wall_size), (top_left[:y] + (y + 1) * wall_size))
        line((top_left[:x] + x * wall_size)-1, (top_left[:y] + y * wall_size), (top_left[:x] + (x) * wall_size)-1, (top_left[:y] + (y + 1) * wall_size))
      end
      if box[:right]
        line((top_left[:x] + (x+ 1) * wall_size), (top_left[:y] + y * wall_size), (top_left[:x] + (x + 1) * wall_size), (top_left[:y] + (y + 1) * wall_size))
        line((top_left[:x] + (x+ 1) * wall_size)-1, (top_left[:y] + y * wall_size), (top_left[:x] + (x + 1) * wall_size)-1, (top_left[:y] + (y + 1) * wall_size))
      end
    end
  end
  
  @dot = stack { image "bieber.jpeg" }
  @dot.move(cursor[:x], cursor[:y])
  
  
  keypress do |k|
    position = check_path(cursor[:x], cursor[:y], margin, wall_size)
    
    cell = grid[position[:y]][position[:x]]
    
    # para grid[cell[:y]][cell[:x]]
    
    case k
    when :up
      @dot.move(cursor[:x], cursor[:y] -= wall_size) if cursor[:y] - wall_size > 0 if !cell[:top]
    when :down
      @dot.move(cursor[:x], cursor[:y] += wall_size) if cursor[:y] + wall_size < app_height - (margin + img_height - 1) if !cell[:bottom]
    when :right
      @dot.move(cursor[:x] += wall_size, cursor[:y]) if cursor[:x] + wall_size < app_width - (margin + img_width - 1) if !cell[:right]
    when :left
      @dot.move(cursor[:x] -= wall_size, cursor[:y]) if cursor[:x] - wall_size > 0 if !cell[:left]
    end
  end

end

def check_path x, y, margin, wall_size
  value = {}
  value[:x] = (x - margin - 1) / wall_size
  value[:y] = (y - margin - 1) / wall_size
  value
end