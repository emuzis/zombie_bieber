app_height = 500
app_width = 500

margin = 10
wall_size = 2*margin

cursor = { :x => margin, :y => margin }

Shoes.app :height => app_height, :width => app_width do
  
  #draw border
  line(margin, margin, app_height - margin, margin)
  line(app_height - margin, margin, app_height - margin, app_width - margin)
  line(app_height - margin, app_width - margin, margin, app_height - margin)
  line(margin, app_height - margin, margin, margin)

  @dot = stack { image "bieber.jpeg" }
  @dot.move(cursor[:x], cursor[:y])
  
  keypress do |k|
    case k
    when :up
      @dot.move(cursor[:x], cursor[:y] -= wall_size)
    when :down
       @dot.move(cursor[:x], cursor[:y] += wall_size)
    when :right
      @dot.move(cursor[:x] += wall_size, cursor[:y])
    when :left
      @dot.move(cursor[:x] -= wall_size, cursor[:y])
    end
  end

end