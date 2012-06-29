require 'grid'
require 'socket'

IMG_HEIGHT  = 48
IMG_WIDTH   = 48
BORDER      = 1
EASY        = {:row => 4,   :col => 4}
MEDIUM      = {:row => 10,  :col => 10}
HARD        = {:row => 15,  :col => 15}
MARGIN      = IMG_HEIGHT / 2

BLOCK_SIZE  = { :x => (IMG_WIDTH) + (BORDER * 2), :y => (IMG_HEIGHT) + (BORDER * 2) }

BIEBER    = "bieber2.jpeg"
FINISH    = "zombieber.png"
WELCOME   = "welcome.png"
GAME_OVER = "finish.png"

SOCKET = UDPSocket.new
SOCKET.bind('0.0.0.0', 6868)

@@thread = nil


def landing_page parent_window, mode
  text = "Finished in #{@@steps_count} steps and #{(Time.now - @@start_time).round(0)} seconds" if mode == :game_over
  parent_window.close if parent_window
  Shoes.app(:height => 720, :width => 960, :title => "Welcome", :resizable => false) do
    
    welcome_img = stack { image instance_eval mode.to_s.upcase }
    @option = :easy
    opton_box = stack {
      list_box :items => [:easy, :medium, :hard] do |list|
        @option = list.text
      end
    }
    start_btn = stack {
      button "Start!!" do
        start_game @option
        close
      end
    }
    
    text = stack { caption text, :fill => "FFFFFF" }
    welcome_img.move(0,0)
    opton_box.move(650, 400)
    start_btn.move(650, 450)
    text.move(0,0)
  end
end


def start_game size
  
  @@row_num = instance_eval(size.to_s.upcase)[:row]
  @@col_num = instance_eval(size.to_s.upcase)[:col]
  
  @@app_height    = (IMG_HEIGHT + BORDER * 2) * @@row_num + MARGIN * 2
  @@app_width     = (IMG_WIDTH + BORDER * 2) * @@col_num + MARGIN * 2
  top_left      = { :x => MARGIN, :y => MARGIN }
  top_right     = { :x => @@app_width - MARGIN, :y => MARGIN }
  bottom_right  = { :x => @@app_width - MARGIN, :y => @@app_height - MARGIN }
  bottom_left   = { :x => MARGIN, :y => @@app_height - MARGIN }
  Shoes.app(:height => @@app_height, :width => @@app_width, :title => "Zombieber", :resizable => false) do
    background white
    s = stack :width => @@app_width, :height => @@app_height do
      @@cursor      = { :x => MARGIN + BORDER, :y => MARGIN + BORDER }
      @@grid        = Grid.new(@@row_num,@@col_num).grid_hash
      @@start_time  = Time.now
      @@steps_count = 0
      @@end_point   = { :x => rand(@@col_num / 2) + @@col_num / 2, :y => rand(@@row_num / 2) + @@row_num / 2}
    
      finish_flag = stack { image FINISH, :width => IMG_WIDTH, :height => IMG_HEIGHT }
      finish_flag.move((top_left[:x] + @@end_point[:x] * BLOCK_SIZE[:x]), (top_left[:y] + @@end_point[:y] * BLOCK_SIZE[:y]))
    
      @@grid.each_with_index do |row, y|
        row.each_with_index do |box, x|
          if box[:top]
            line((top_left[:x] + x * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y]), (top_left[:x] + (x + 1) * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y]))
            line((top_left[:x] + x * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y])-1, (top_left[:x] + (x + 1) * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y])-1)
          end
          if box[:bottom]
            line((top_left[:x] + x * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]), (top_left[:x] + (x + 1) * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((top_left[:x] + x * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y])-1, (top_left[:x] + (x + 1) * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y])-1)
          end
          if box[:left]
            line((top_left[:x] + x * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y]), (top_left[:x] + (x) * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((top_left[:x] + x * BLOCK_SIZE[:x])-1, (top_left[:y] + y * BLOCK_SIZE[:y]), (top_left[:x] + (x) * BLOCK_SIZE[:x])-1, (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]))
          end
          if box[:right]
            line((top_left[:x] + (x+ 1) * BLOCK_SIZE[:x]), (top_left[:y] + y * BLOCK_SIZE[:y]), (top_left[:x] + (x + 1) * BLOCK_SIZE[:x]), (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]))
            line((top_left[:x] + (x+ 1) * BLOCK_SIZE[:x])-1, (top_left[:y] + y * BLOCK_SIZE[:y]), (top_left[:x] + (x + 1) * BLOCK_SIZE[:x])-1, (top_left[:y] + (y + 1) * BLOCK_SIZE[:y]))
          end
        end
      end
  
      @bieber = stack { image BIEBER, :width => IMG_WIDTH, :height => IMG_HEIGHT }
      @bieber.move(@@cursor[:x], @@cursor[:y])
    
      keypress do |k|
        moving(@bieber, k)
      end
    end


    @@thread = Thread.start do
      while SOCKET do
        text, sender = SOCKET.recvfrom(4096)
      
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



landing_page nil, :welcome


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
    object.move(@@cursor[:x], @@cursor[:y] += BLOCK_SIZE[:y]) if @@cursor[:y] + BLOCK_SIZE[:y] < @@app_height - (MARGIN + IMG_HEIGHT - 1) if !cell[:bottom]
  when :right
    object.move(@@cursor[:x] += BLOCK_SIZE[:x], @@cursor[:y]) if @@cursor[:x] + BLOCK_SIZE[:x] < @@app_width - (MARGIN + IMG_WIDTH - 1) if !cell[:right]
  when :left
    object.move(@@cursor[:x] -= BLOCK_SIZE[:x], @@cursor[:y]) if @@cursor[:x] - BLOCK_SIZE[:x] > 0 if !cell[:left]
  end
  position_after = check_path(@@cursor[:x], @@cursor[:y])
  @@steps_count += 1 if position_before != position_after
  if @@end_point[:x] == position_after[:x] && @@end_point[:y] == position_after[:y]
    # alert("Finished in #{(Time.now - @@start_time).round(0)} seconds and #{@@steps_count} steps")
    landing_page self, :game_over
    return true
  end
  return false
end

