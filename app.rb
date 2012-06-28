img_height = 24
img_width = 24

app_height = img_height * img_height
app_width = img_width * img_width

margin = img_height / 2
wall_size = 2 * margin

cursor = { :x => margin, :y => margin }

top_left = { :x => margin, :y => margin }
top_right = { :x => app_height - margin, :y => margin }
bottom_right = { :x => app_height - margin, :y => app_width - margin }
bottom_left = { :x => margin, :y => app_width - margin }

Shoes.app :height => app_height, :width => app_width do
  
  #draw border
  line(top_left[:x], top_left[:y], top_right[:x], top_right[:y])
  line(top_right[:x], top_right[:y], bottom_right[:x], bottom_right[:y])
  line(bottom_right[:x], bottom_right[:y], bottom_left[:x], bottom_left[:y])
  line(bottom_left[:x], bottom_left[:y], top_left[:x], top_left[:y])

  @dot = stack { image "bieber.jpeg" }
  @dot.move(cursor[:x], cursor[:y])
  
  keypress do |k|
    case k
    when :up
      @dot.move(cursor[:x], cursor[:y] -= wall_size) if cursor[:y] - wall_size > 0
    when :down
       @dot.move(cursor[:x], cursor[:y] += wall_size) if cursor[:y] + wall_size < app_height - (margin + img_height - 1)
    when :right
      @dot.move(cursor[:x] += wall_size, cursor[:y]) if cursor[:x] + wall_size < app_width - (margin + img_width - 1)
    when :left
      @dot.move(cursor[:x] -= wall_size, cursor[:y]) if cursor[:x] - wall_size > 0
    end
  end

end