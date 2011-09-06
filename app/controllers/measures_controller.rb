require 'withings'
include Withings

class MeasuresController < ApplicationController
  helper :measures

  def index
    if current_person or params["person_id"]
      @person = current_person if current_person
      if params['person_id']
        person_id = Person.find params['person_id']
        @person = Person.find person_id
        if @person.private
          redirect_to people_url, :notice => "Sorry that data is private."
        end
      end

      @posts = Post.where(:person_id=>@person.id).order('created_at desc').limit(5)
      @measures = @person.measures.order('measure_date desc').paginate :per_page=> (@person.measures_to_show || 7), :page => params[:page]
      @allmeasures = @person.measures
      @max_days = @person.measures.size

      if @person.has_trend
        @last7 = @person.last(7)
        @last30 = @person.last(30)
        @lastall = @person.last(@max_days)
        @in3months = @person.in3months

        if @measures[0] and @last7
          @week_measures = @person.get_measures(7)
        else
          @goaldate = "Not enough data"
        end

        @month_measures = @person.get_measures(30) if @last30
        @all_measures = @person.get_measures(@person.measures.size) if @lastall

        @karma_rank = @person.karma_rank
      end
    else
      redirect_to people_url
      #redirect_to people_url, :notice => "Select a person."
    end
  end

  def chart
    @person = Person.find params[:person_id]
    #TODO deal with what if the persons data is private, only show it to them

    @measuredate = Date.parse(params[:measuredate])
    @limit = 7 unless params[:limit]
    @max_days = @person.measures.size
    @last = @person.last(@limit)

    @measures = Measure.where('person_id = :person_id and measure_date <= :measuredate', :person_id => @person.id, :measuredate=>@measuredate).order('measure_date desc').limit(@limit)
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

  def refresh
    if (person_signed_in?)
      measures_count = current_person.refresh
    end
    update_trend
    redirect_to measures_url, :notice => 'Retrieved ' + measures_count.to_s + ' measures.'
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
    ActiveRecord::Base.connection.execute('update measures set trend = null, karma=null, trend = null, delta=null;')
    Person.all.each do |person|
      @measures = Measure.where(:person_id=>person.id).order('measure_date asc')
      counter = 0
      trend_days = 6
      alpha = person.alpha
      weightmult = 2
      trendmult = 10

      trend = 0
      delta = 0
      karma = 0
      previous_trend = 0

      if @measures.size > 6
        @measures.each do |measure|
          if counter == 0
            forecast = 0
            @measures[0..6].each do |m|
              forecast+= m.item
            end
            forecast = forecast / 7
            measure.forecast = forecast
          else
            forecast = @measures[counter - 1].trend
          end

          trend = (alpha * measure.item) + (1 - alpha) * forecast
          trenddiff = (trend - previous_trend)
          diff = measure.item - person.goal
          unless counter == 0
            measure.karma = 100 - (diff * weightmult) - (trenddiff * trendmult)
            measure.karma = 100 if measure.karma > 100
          end

          measure.trend = trend
          previous_trend = trend

          delta = measure.item - forecast
          measure.forecast = forecast
          measure.delta = delta
          measure.save
          counter = counter + 1
        end
      end
    end
  end
end
