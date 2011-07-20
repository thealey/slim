require 'withings'
include Withings

class MeasuresController < ApplicationController

  def index
    if current_person or params["person_id"]
      @person = current_person if current_person
      if params['person_id']
        person_id = Person.find params['person_id']
        @person = Person.find person_id
      end

      @measures = Measure.where(:person_id => @person.id).order('measure_date desc').paginate :per_page=> 7, :page => params[:page]

      if @measures[0] and @measures[6]
        @last7 = @measures[0].trend - @measures[6].trend
      else
        @last7 = nil 
      end

      if @measures[14]
        @last14 = @measures[0].trend - @measures[14].trend
      else
        @last14 = nil
      end
      if @measures[30]
        @last30 = @measures[0].trend - @measures[30].trend
      else
        @last30 = nil
      end

      @goal_weight = @person.goal_weight

      if @measures[0] and @last7
        if @goal_weight < @measures[0].weight
          togo = @measures[0].weight - @goal_weight
          @goaldate = (Time.now + (togo / -@last7).weeks).to_s(:long)
        else
          @goaldate = "At or below goal weight"
        end
      else
        @goaldate = "Not enough data"
      end

      week_measures = Measure.order('measure_date desc').limit(7)
      @lcurl7 = getchart(week_measures, "7 Day Trend", 7)

      month_measures = Measure.order('measure_date desc').limit(30)
      @lcurl30 = getchart(month_measures, "30 Day Trend", 30)

      all_measures = Measure.order('measure_date desc').limit(200)
      @lcurlall = getchart(all_measures, "200 Day Trend", 200)
    else
      redirect_to people_url, :notice => "Select a person."
    end
  end

  def getchart(measures, title, daylimit)
    trends = Array.new
    weights = Array.new
    max_weight = 0
    min_weight = 1000
    lcurl = ''

    measures.each do |measure|
      return '' if measure.trend.nil?
      trends << measure.trend
      weights << measure.weight
      min_weight = measure.weight if measure.weight < min_weight
      max_weight = measure.weight if measure.weight > max_weight
    end
    max_weight = max_weight + 1

    scaled_trends = scale_array(trends, min_weight, max_weight)
    scaled_weights = scale_array(weights, min_weight, max_weight)
    #debugger

    GoogleChart::LineChart.new('320x200', title, false) do |lc|
      lc.show_legend = false
      lc.data "Trend", scaled_trends, '9981'
      lc.data "Weight", scaled_weights, '667B99'
      lc.axis :y, :range => [min_weight, max_weight], :color => '667B99', :font_size => 10, :alignment => :center
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

  def show
    @measure = Measure.find(params[:id])
  end

  def new
    @measure = Measure.new
  end

  def create
    @measure = Measure.new(params[:measure])
    if @measure.save
      update_trend
      redirect_to measures_url, :notice => "Successfully created measure."
    else
      render :action => 'new'
    end
  end

  def edit
    @measure = Measure.find(params[:id])
  end

  def update
    @measure = Measure.find(params[:id])
    if @measure.update_attributes(params[:measure])
      redirect_to @measure, :notice  => "Successfully updated measure."
    else
      render :action => 'edit'
    end
  end

  def importall
    if (logged_in?)
      wuser = Withings::User.info(current_person.withings_id, current_person.withings_api_key)
      wuser.share()

      page = 1

      begin 
        measurements = wuser.measurement_groups(:per_page => 20, :page => page, :end_at => Time.now)

        measurements.each do |measurement|
          if measurement.weight and measurement.fat and measurement.taken_at
            measure = Measure.new
            measure.person_id = current_person.id
            measure.weight = measurement.weight * 2.20462262
            measure.fat = measurement.fat * 2.20462262
            measure.measure_date = measurement.taken_at
            measure.save
          end
        end    
        page = page + 1
      end while measurements.size > 0
    end
    update_trend
    @measures = Measure.all
    render :action => 'index'
  end

  def updateall
    if (logged_in?)
      wuser = Withings::User.info(current_person.withings_id, current_person.withings_api_key)
      wuser.share()
      measurements = wuser.measurement_groups(:start_at=>Measure.first.measure_date + 1.minute, :end_at => Time.now)

      measurements.each do |measurement|
        measure = Measure.new
        measure.person_id = current_person.id
        measure.weight = measurement.weight * 2.20462262
        measure.fat = measurement.fat * 2.20462262
        measure.measure_date = measurement.taken_at
        measure.save
      end    
    end
    update_trend
    redirect_to measures_url, :notice => "Successfully updated."
  end


  def deleteall
    Measure.destroy_all
    redirect_to measures_url, :notice => "Successfully destroyed all measures."
  end

  def destroy
    @measure = Measure.find(params[:id])
    @measure.destroy
    update_trend
    redirect_to measures_url, :notice => "Successfully destroyed measure."
  end

  def update_trend
    @measures = Measure.order('measure_date asc')
    counter = 0
    trend_days = 6
    alpha = 0.1
    trend = 0
    delta = 0

    @measures.each do |measure|
      if counter == 0
        #debugger
        forecast = 0
        @measures[0..6].each do |m|
          forecast+= m.weight
        end
        forecast = forecast / 7
        measure.forecast = forecast
      else
        forecast = @measures[counter - 1].trend
      end

      trend = (alpha * measure.weight) + (1 - alpha) * forecast
      delta = measure.weight - forecast
      measure.forecast = forecast
      measure.trend = trend
      measure.delta = delta
      measure.save

      counter = counter + 1
    end

    #redirect_to measures_url, :notice => "Successfully updated trend data."
  end
end
