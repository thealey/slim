module ApplicationHelper
  def getchart(measures, title, daylimit, person, size)
    max_days = person.measures.size
    trends = Array.new
    weights = Array.new
    fats = Array.new
    goals = Array.new
    karmas = Array.new

    max = 0
    min = 1000
    lcurl = ''

    measures.each do |measure|
      return '' if measure.trend.nil?
      trends << measure.trend
      fats << measure.fatpercentage
      weights << measure.weight
      karmas << measure.karma - 10 if measure.karma

      min = measure.item if measure.item < min
      max = measure.item if measure.item > max

      min = measure.trend if measure.trend < min
      max = measure.trend if measure.trend > max
      goals << person.goal
    end
    #max = max + 1

    min = person.goal - person.goal * 0.02 if daylimit == max_days

    scaled_trends = scale_array(trends, min, max)
    scaled_weights = scale_array(weights, min, max)
    scaled_fats = scale_array(fats, min, max)
    scaled_karmas = scale_array(karmas, 0, 100)
    #scaled_karmas.reverse!
    scaled_goals = scale_array(goals, min, max)

    GoogleChart::LineChart.new(size, title, false) do |lc|
      lc.show_legend = true
      lc.data "Trend", scaled_trends, 'D80000'
      if person.goal_type == 'lbs'
        lc.data "Weight", scaled_weights, 'BDBDBD'
      end
      if person.goal_type == '%fat'
        #lc.data "%Fat", scaled_fats, 'BDBDBD'
      end
      lc.data "Goal", scaled_goals, '254117'
      lc.fill(:background, :solid, {:color => 'ffffff'})
      #lc.data "Karma", scaled_karmas, 'B8B8B8'
      lc.axis :y, :range => [min, max], :color => '667B99', :font_size => 10, :alignment => :center
      lc.axis :x, :range => [daylimit,1], :color => '667B99', :font_size => 10, :alignment => :center
      lc.grid :x_step => 5, :y_step => 5, :length_segment => 1, :length_blank => 0
      lcurl = lc.to_url(:chds=>'a')
    end
    return lcurl
  end

  def scale_array(myarray, min, max)
    scaled_array = Array.new
    old_range = (max - min)
    myarray.reverse!

    myarray.each do |item|
      scaled_array << (((item - min) * 100) / old_range)
    end
    return scaled_array
  end  
end
