require 'grid'
start_time  = Time.now
steps_count = 0
end_point   = { :x => rand(col_num), :y => rand(row_num) }

img_height  = 24
img_width   = 24
border      = 1
row_num     = 24
col_num     = 24
margin      = img_height / 2
app_height  = (img_height + border * 2) * 24 + margin * 2
app_width   = (img_height + border * 2) * 24 + margin * 2

block_size  = (2 * margin) + (border * 2)

cursor        = { :x => margin + border, :y => margin + border }
top_left      = { :x => margin, :y => margin }
top_right     = { :x => app_height - margin, :y => margin }
bottom_right  = { :x => app_height - margin, :y => app_width - margin }
bottom_left   = { :x => margin, :y => app_width - margin }


grid = Grid.new(row_num,col_num).grid_hash

Shoes.app :height => app_height, :width => app_width do
  @finish_flag = stack { image "finish.jpeg" }
  @finish_flag.move((top_left[:x] + end_point[:x] * block_size), (top_left[:y] + end_point[:y] * block_size))
  
  grid.each_with_index do |row, y|
    row.each_with_index do |box, x|
      if box[:top]
        line((top_left[:x] + x * block_size), (top_left[:y] + y * block_size), (top_left[:x] + (x + 1) * block_size), (top_left[:y] + y * block_size))
        line((top_left[:x] + x * block_size), (top_left[:y] + y * block_size)-1, (top_left[:x] + (x + 1) * block_size), (top_left[:y] + y * block_size)-1)
      end
      if box[:bottom]
        line((top_left[:x] + x * block_size), (top_left[:y] + (y + 1) * block_size), (top_left[:x] + (x + 1) * block_size), (top_left[:y] + (y + 1) * block_size))
        line((top_left[:x] + x * block_size), (top_left[:y] + (y + 1) * block_size)-1, (top_left[:x] + (x + 1) * block_size), (top_left[:y] + (y + 1) * block_size)-1)
      end
      if box[:left]
        line((top_left[:x] + x * block_size), (top_left[:y] + y * block_size), (top_left[:x] + (x) * block_size), (top_left[:y] + (y + 1) * block_size))
        line((top_left[:x] + x * block_size)-1, (top_left[:y] + y * block_size), (top_left[:x] + (x) * block_size)-1, (top_left[:y] + (y + 1) * block_size))
      end
      if box[:right]
        line((top_left[:x] + (x+ 1) * block_size), (top_left[:y] + y * block_size), (top_left[:x] + (x + 1) * block_size), (top_left[:y] + (y + 1) * block_size))
        line((top_left[:x] + (x+ 1) * block_size)-1, (top_left[:y] + y * block_size), (top_left[:x] + (x + 1) * block_size)-1, (top_left[:y] + (y + 1) * block_size))
      end
    end
  end
  
  @bieber = stack { image "bieber.jpeg" }
  @bieber.move(cursor[:x], cursor[:y])
  
  keypress do |k|
    position_before = check_path(cursor[:x], cursor[:y], margin, block_size)
    
    cell = grid[position_before[:y]][position_before[:x]]
    
    case k
    when :up
      @bieber.move(cursor[:x], cursor[:y] -= block_size) if cursor[:y] - block_size > 0 if !cell[:top]
    when :down
      @bieber.move(cursor[:x], cursor[:y] += block_size) if cursor[:y] + block_size < app_height - (margin + img_height - 1) if !cell[:bottom]
    when :right
      @bieber.move(cursor[:x] += block_size, cursor[:y]) if cursor[:x] + block_size < app_width - (margin + img_width - 1) if !cell[:right]
    when :left
      @bieber.move(cursor[:x] -= block_size, cursor[:y]) if cursor[:x] - block_size > 0 if !cell[:left]
    end
    position_after = check_path(cursor[:x], cursor[:y], margin, block_size)
    steps_count += 1 if position_before != position_after
    end_time = Time.now
    alert("Finished in #{(end_time - start_time).round(0)} seconds and #{steps_count} steps") if end_point[:x] == position_after[:x] && end_point[:y] == position_after[:y]
  end

end

def check_path x, y, margin, block_size
  value = {}
  value[:x] = (x - margin - 1) / block_size
  value[:y] = (y - margin - 1) / block_size
  value
end