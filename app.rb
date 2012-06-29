require 'grid'
require 'socket'

IMG_HEIGHT  = 64
IMG_WIDTH   = 64
BORDER      = 1
ROW_NUM     = 10
COL_NUM     = 10
MARGIN      = IMG_HEIGHT / 2
APP_HEIGHT  = (IMG_HEIGHT + BORDER * 2) * ROW_NUM + MARGIN * 2
APP_WIDTH   = (IMG_WIDTH + BORDER * 2) * COL_NUM + MARGIN * 2

BLOCK_SIZE  = { :x => (IMG_WIDTH) + (BORDER * 2), :y => (IMG_HEIGHT) + (BORDER * 2) }

TOP_LEFT      = { :x => MARGIN, :y => MARGIN }
TOP_RIGHT     = { :x => APP_WIDTH - MARGIN, :y => MARGIN }
BOTTOM_RIGHT  = { :x => APP_WIDTH - MARGIN, :y => APP_HEIGHT - MARGIN }
BOTTOM_LEFT   = { :x => MARGIN, :y => APP_HEIGHT - MARGIN }

BIEBER = "bieber2.jpeg"
FINISH = "zombieber.png"

def welcome_screen
  Shoes.app(:height => 300, :width => 300, :title => "Welcome", :resizable => false) do
    para "welcome"
    button "Start!!" do
      start_game
      close
    end
  end
end

def start_game
  Shoes.app(:height => APP_HEIGHT, :width => APP_WIDTH, :title => "Zombieber", :resizable => false) do
    background white
    s = stack :width => APP_WIDTH, :height => APP_HEIGHT do
      @@cursor      = { :x => MARGIN + BORDER, :y => MARGIN + BORDER }
      @@grid        = Grid.new(ROW_NUM,COL_NUM).grid_hash
      @@start_time  = Time.now
      @@steps_count = 0
      @@end_point   = { :x => rand(COL_NUM), :y => rand(ROW_NUM) }
    
      finish_flag = stack { image FINISH, :width => IMG_WIDTH, :height => IMG_HEIGHT }
      finish_flag.move((TOP_LEFT[:x] + @@end_point[:x] * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + @@end_point[:y] * BLOCK_SIZE[:y]))
    
      @@grid.each_with_index do |row, y|
        row.each_with_index do |box, x|
          if box[:top]
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]))
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y])-1, (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y])-1)
          end
          if box[:bottom]
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y])-1, (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y])-1)
          end
          if box[:left]
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((TOP_LEFT[:x] + x * BLOCK_SIZE[:x])-1, (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x) * BLOCK_SIZE[:x])-1, (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]))
          end
          if box[:right]
            line((TOP_LEFT[:x] + (x+ 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x]), (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((TOP_LEFT[:x] + (x+ 1) * BLOCK_SIZE[:x])-1, (TOP_LEFT[:y] + y * BLOCK_SIZE[:y]), (TOP_LEFT[:x] + (x + 1) * BLOCK_SIZE[:x])-1, (TOP_LEFT[:y] + (y + 1) * BLOCK_SIZE[:y]))
          end
        end
      end
  
      @bieber = stack { image BIEBER, :width => IMG_WIDTH, :height => IMG_HEIGHT }
      @bieber.move(@@cursor[:x], @@cursor[:y])
    
      keypress do |k|
        moving(@bieber, k)
      end
    end

    s = UDPSocket.new
    s.bind('0.0.0.0', 6868)
    Thread.start do
      while true do
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
      end
    end
  end
end

def game_over game_window
  game_window.close
  Shoes.app(:height => 100, :width => 500, :title => "Congrats!", :resizable => false) do
    para "Finished in #{@@steps_count} steps and #{(Time.now - @@start_time).round(0)} seconds"
    button "restart game?" do
      start_game
      close
    end
  end
end

welcome_screen


def check_path x, y
  value = {}
  value[:x] = (x - MARGIN - 1) / BLOCK_SIZE[:x]
  value[:y] = (y - MARGIN - 1) / BLOCK_SIZE[:y]
  value
end

def moving (object, direction)
  position_before = check_path(@@cursor[:x], @@cursor[:y])
  cell = @@grid[position_before[:y]][position_before[:x]]
  case direction
  when :up
    object.move(@@cursor[:x], @@cursor[:y] -= BLOCK_SIZE[:y]) if @@cursor[:y] - BLOCK_SIZE[:y] > 0 if !cell[:top]
  when :down
    object.move(@@cursor[:x], @@cursor[:y] += BLOCK_SIZE[:y]) if @@cursor[:y] + BLOCK_SIZE[:y] < APP_HEIGHT - (MARGIN + IMG_HEIGHT - 1) if !cell[:bottom]
  when :right
    object.move(@@cursor[:x] += BLOCK_SIZE[:x], @@cursor[:y]) if @@cursor[:x] + BLOCK_SIZE[:x] < APP_WIDTH - (MARGIN + IMG_WIDTH - 1) if !cell[:right]
  when :left
    object.move(@@cursor[:x] -= BLOCK_SIZE[:x], @@cursor[:y]) if @@cursor[:x] - BLOCK_SIZE[:x] > 0 if !cell[:left]
  end
  position_after = check_path(@@cursor[:x], @@cursor[:y])
  @@steps_count += 1 if position_before != position_after
  if @@end_point[:x] == position_after[:x] && @@end_point[:y] == position_after[:y]
    # alert("Finished in #{(Time.now - @@start_time).round(0)} seconds and #{@@steps_count} steps")
    game_over self
    return true
  end
  return false
end

