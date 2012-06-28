require 'grid'

IMG_HEIGHT  = 24
IMG_WIDTH   = 24
BORDER      = 1
ROW_NUM     = 24
COL_NUM     = 24
MARGIN      = IMG_HEIGHT / 2
APP_HEIGHT  = (IMG_HEIGHT + BORDER * 2) * 24 + MARGIN * 2
APP_WIDTH   = (IMG_HEIGHT + BORDER * 2) * 24 + MARGIN * 2

BLOCK_SIZE  = (2 * MARGIN) + (BORDER * 2)

TOP_LEFT      = { :x => MARGIN, :y => MARGIN }
TOP_RIGHT     = { :x => APP_HEIGHT - MARGIN, :y => MARGIN }
BOTTOM_RIGHT  = { :x => APP_HEIGHT - MARGIN, :y => APP_WIDTH - MARGIN }
BOTTOM_LEFT   = { :x => MARGIN, :y => APP_WIDTH - MARGIN }




Shoes.app :height => APP_HEIGHT, :width => APP_WIDTH do
  s = stack :width => APP_WIDTH, :height => APP_HEIGHT do
    cursor      = { :x => MARGIN + BORDER, :y => MARGIN + BORDER }
    grid        = Grid.new(ROW_NUM,COL_NUM).grid_hash
    start_time  = Time.now
    steps_count = 0
    end_point   = { :x => rand(COL_NUM), :y => rand(ROW_NUM) }
    
    finish_flag = stack { image "finish.jpeg" }
    finish_flag.move((TOP_LEFT[:x] + end_point[:x] * BLOCK_SIZE), (TOP_LEFT[:y] + end_point[:y] * BLOCK_SIZE))
    
    grid.each_with_index do |row, y|
      row.each_with_index do |box, x|
        if box[:top]
          line((TOP_LEFT[:x] + x * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE))
          line((TOP_LEFT[:x] + x * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE)-1, (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE)-1)
        end
        if box[:bottom]
          line((TOP_LEFT[:x] + x * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE))
          line((TOP_LEFT[:x] + x * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE)-1, (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE)-1)
        end
        if box[:left]
          line((TOP_LEFT[:x] + x * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE), (TOP_LEFT[:x] + (x) * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE))
          line((TOP_LEFT[:x] + x * BLOCK_SIZE)-1, (TOP_LEFT[:y] + y * BLOCK_SIZE), (TOP_LEFT[:x] + (x) * BLOCK_SIZE)-1, (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE))
        end
        if box[:right]
          line((TOP_LEFT[:x] + (x+ 1) * BLOCK_SIZE), (TOP_LEFT[:y] + y * BLOCK_SIZE), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE))
          line((TOP_LEFT[:x] + (x+ 1) * BLOCK_SIZE)-1, (TOP_LEFT[:y] + y * BLOCK_SIZE), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE)-1, (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE))
        end
      end
    end
  
    @bieber = stack { image "bieber.jpeg" }
    @bieber.move(cursor[:x], cursor[:y])
  
    keypress do |k|
      position_before = check_path(cursor[:x], cursor[:y], MARGIN, BLOCK_SIZE)
    
      cell = grid[position_before[:y]][position_before[:x]]
      case k
      when :up
        @bieber.move(cursor[:x], cursor[:y] -= BLOCK_SIZE) if cursor[:y] - BLOCK_SIZE > 0 if !cell[:top]
      when :down
        @bieber.move(cursor[:x], cursor[:y] += BLOCK_SIZE) if cursor[:y] + BLOCK_SIZE < APP_HEIGHT - (MARGIN + IMG_HEIGHT - 1) if !cell[:bottom]
      when :right
        @bieber.move(cursor[:x] += BLOCK_SIZE, cursor[:y]) if cursor[:x] + BLOCK_SIZE < APP_WIDTH - (MARGIN + IMG_WIDTH - 1) if !cell[:right]
      when :left
        @bieber.move(cursor[:x] -= BLOCK_SIZE, cursor[:y]) if cursor[:x] - BLOCK_SIZE > 0 if !cell[:left]
      end
      position_after = check_path(cursor[:x], cursor[:y], MARGIN, BLOCK_SIZE)
      steps_count += 1 if position_before != position_after
      end_time = Time.now
      if end_point[:x] == position_after[:x] && end_point[:y] == position_after[:y]
        alert("Finished in #{(end_time - start_time).round(0)} seconds and #{steps_count} steps")
        # s.clear()
      end
    end
  end
end

def check_path x, y
  value = {}
  value[:x] = (x - MARGIN - 1) / BLOCK_SIZE
  value[:y] = (y - MARGIN - 1) / BLOCK_SIZE
  value
end