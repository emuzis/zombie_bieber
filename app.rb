require 'grid'
require 'socket'

BORDER      = 1
EASY        = {:row => 4,   :col => 4, :img_height => 48, :img_width => 48}
MEDIUM      = {:row => 10,  :col => 10, :img_height => 48, :img_width => 48}
HARD        = {:row => 15,  :col => 15, :img_height => 48, :img_width => 48}
JOSS        = {:row => 60,  :col => 60, :img_height => 12, :img_width => 12}

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
    
    keypress do |k|
      if k.to_s == "j"
        start_game :joss
        close
      end
    end
    
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
  @@thread.exit if @@thread
  @@img_height = instance_eval(size.to_s.upcase)[:img_height]
  @@img_width = instance_eval(size.to_s.upcase)[:img_width]
  
  @@margin = @@img_height / 2
  @@block_size = { :x => (@@img_width) + (BORDER * 2), :y => (@@img_height) + (BORDER * 2) }
  
  @@row_num = instance_eval(size.to_s.upcase)[:row]
  @@col_num = instance_eval(size.to_s.upcase)[:col]
  
  @@app_height    = (@@img_height + BORDER * 2) * @@row_num + @@margin * 2
  @@app_width     = (@@img_width + BORDER * 2) * @@col_num + @@margin * 2
  top_left      = { :x => @@margin, :y => @@margin }
  top_right     = { :x => @@app_width - @@margin, :y => @@margin }
  bottom_right  = { :x => @@app_width - @@margin, :y => @@app_height - @@margin }
  bottom_left   = { :x => @@margin, :y => @@app_height - @@margin }

  Shoes.app(:height => @@app_height, :width => @@app_width, :title => "Zombieber", :resizable => false) do
    background white
    strokewidth(2)
    s = stack :width => @@app_width, :height => @@app_height do

      @@cursor      = { :x => @@margin + BORDER, :y => @@margin + BORDER }
      @@grid        = Grid.new(@@row_num,@@col_num).grid_hash
      @@start_time  = Time.now
      @@steps_count = 0
      @@end_point   = { :x => rand(@@col_num / 2) + @@col_num / 2, :y => rand(@@row_num / 2) + @@row_num / 2}
    
      finish_flag = stack { image FINISH, :width => @@img_width, :height => @@img_height }
      finish_flag.move((top_left[:x] + @@end_point[:x] * @@block_size[:x]), (top_left[:y] + @@end_point[:y] * @@block_size[:y]))
    
      @@grid.each_with_index do |row, y|
        row.each_with_index do |box, x|
          if box[:top]
            line((top_left[:x] + x * @@block_size[:x]), (top_left[:y] + y * @@block_size[:y]), (top_left[:x] + (x + 1) * @@block_size[:x]), (top_left[:y] + y * @@block_size[:y]))
          end
          if box[:bottom]
            line((top_left[:x] + x * @@block_size[:x]), (top_left[:y] + (y + 1) * @@block_size[:y]), (top_left[:x] + (x + 1) * @@block_size[:x]), (top_left[:y] + (y + 1) * @@block_size[:y]))
          end
          if box[:left]
            line((top_left[:x] + x * @@block_size[:x]), (top_left[:y] + y * @@block_size[:y]), (top_left[:x] + (x) * @@block_size[:x]), (top_left[:y] + (y + 1) * @@block_size[:y]))
          end
          if box[:right]
            line((top_left[:x] + (x+ 1) * @@block_size[:x]), (top_left[:y] + y * @@block_size[:y]), (top_left[:x] + (x + 1) * @@block_size[:x]), (top_left[:y] + (y + 1) * @@block_size[:y]))
          end
        end
      end
  
      @bieber = stack { image BIEBER, :width => @@img_width, :height => @@img_height }
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
          when /^sl/ then action = :left
          when /^sr/ then action = :right
          when /^b/ then action = :up
          when /^f/ then action = :down
        end
    
        moving(@bieber, action) if action
      end
    end
  end
end



landing_page nil, :welcome


def check_path x, y
  value = {}
  value[:x] = (x - @@margin - 1) / @@block_size[:x]
  value[:y] = (y - @@margin - 1) / @@block_size[:y]
  value
end

def moving (object, direction)
  position_before = check_path(@@cursor[:x], @@cursor[:y])
  cell = @@grid[position_before[:y]][position_before[:x]]
  case direction
  when :up
    object.move(@@cursor[:x], @@cursor[:y] -= @@block_size[:y]) if @@cursor[:y] - @@block_size[:y] > 0 if !cell[:top]
  when :down
    object.move(@@cursor[:x], @@cursor[:y] += @@block_size[:y]) if @@cursor[:y] + @@block_size[:y] < @@app_height - (@@margin + @@img_height - 1) if !cell[:bottom]
  when :right
    object.move(@@cursor[:x] += @@block_size[:x], @@cursor[:y]) if @@cursor[:x] + @@block_size[:x] < @@app_width - (@@margin + @@img_width - 1) if !cell[:right]
  when :left
    object.move(@@cursor[:x] -= @@block_size[:x], @@cursor[:y]) if @@cursor[:x] - @@block_size[:x] > 0 if !cell[:left]
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

