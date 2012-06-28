require 'grid'

IMG_HEIGHT  = 24
IMG_WIDTH   = 24
BORDER      = 1
ROW_NUM     = 24
COL_NUM     = 24
MARGIN      = IMG_HEIGHT / 2
APP_HEIGHT  = (IMG_HEIGHT + BORDER * 2) * ROW_NUM + MARGIN * 2
APP_WIDTH   = (IMG_HEIGHT + BORDER * 2) * COL_NUM + MARGIN * 2

BLOCK_SIZE  = (2 * MARGIN) + (BORDER * 2)

TOP_LEFT      = { :x => MARGIN, :y => MARGIN }
TOP_RIGHT     = { :x => APP_HEIGHT - MARGIN, :y => MARGIN }
BOTTOM_RIGHT  = { :x => APP_HEIGHT - MARGIN, :y => APP_WIDTH - MARGIN }
BOTTOM_LEFT   = { :x => MARGIN, :y => APP_WIDTH - MARGIN }


Shoes.app :height => APP_HEIGHT, :width => APP_WIDTH do
  s = stack :width => APP_WIDTH, :height => APP_HEIGHT do
    @@cursor      = { :x => MARGIN + BORDER, :y => MARGIN + BORDER }
    @@grid        = Grid.new(ROW_NUM,COL_NUM).grid_hash
    @@start_time  = Time.now
    @@steps_count = 0
    @@end_point   = { :x => rand(COL_NUM), :y => rand(ROW_NUM) }
    
    finish_flag = stack { image "finish.jpeg" }
    finish_flag.move((TOP_LEFT[:x] + @@end_point[:x] * BLOCK_SIZE), (TOP_LEFT[:y] + @@end_point[:y] * BLOCK_SIZE))
    
    @@grid.each_with_index do |row, y|
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
    @bieber.move(@@cursor[:x], @@cursor[:y])
    
    keypress do |k|
      moving(@bieber, k)
    end
  end

  s = UDPSocket.new
  s.bind('0.0.0.0', 6868)  
  every 1 do
    text, sender = s.recvfrom(4096)
    text = text.split(',')[0]
    action = nil
    case text
      when '32' then action = :left
      when '64' then action = :right
      when '8'  then action = :up
      when '16' then action = :down
    end
      
    moving(@bieber, action) if action

    # @bieber.move(@@cursor[:x], @@cursor[:y] += BLOCK_SIZE)
  end

end

def check_path x, y
  value = {}
  value[:x] = (x - MARGIN - 1) / BLOCK_SIZE
  value[:y] = (y - MARGIN - 1) / BLOCK_SIZE
  value
end

def moving (object, direction)
  position_before = check_path(@@cursor[:x], @@cursor[:y])
  cell = @@grid[position_before[:y]][position_before[:x]]
  case direction
  when :up
    object.move(@@cursor[:x], @@cursor[:y] -= BLOCK_SIZE) if @@cursor[:y] - BLOCK_SIZE > 0 if !cell[:top]
  when :down
    object.move(@@cursor[:x], @@cursor[:y] += BLOCK_SIZE) if @@cursor[:y] + BLOCK_SIZE < APP_HEIGHT - (MARGIN + IMG_HEIGHT - 1) if !cell[:bottom]
  when :right
    object.move(@@cursor[:x] += BLOCK_SIZE, @@cursor[:y]) if @@cursor[:x] + BLOCK_SIZE < APP_WIDTH - (MARGIN + IMG_WIDTH - 1) if !cell[:right]
  when :left
    object.move(@@cursor[:x] -= BLOCK_SIZE, @@cursor[:y]) if @@cursor[:x] - BLOCK_SIZE > 0 if !cell[:left]
  end
  position_after = check_path(@@cursor[:x], @@cursor[:y])
  @@steps_count += 1 if position_before != position_after
  if @@end_point[:x] == position_after[:x] && @@end_point[:y] == position_after[:y]
    alert("Finished in #{(Time.now - @@start_time).round(0)} seconds and #{@@steps_count} steps")
    return true
  end
  return false
end