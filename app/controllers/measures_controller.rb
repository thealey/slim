require 'withings'
include Withings

class MeasuresController < ApplicationController
  helper :measures

  def index
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
    Measure.update_trend
    redirect_to @measure.person, :notice=>'Created new measure.'
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
      measures_count = current_person.refresh_all
    end
    Measure.update_trend
    redirect_to current_person, :notice => 'Retrieved ' + measures_count.to_s + ' measures.'
  end

  def deleteall
    Measure.destroy_all
    redirect_to people_url, :notice => "Successfully destroyed all measures."
  end

  def destroy
    @measure = Measure.find(params[:id])
    @measure.destroy
    Measure.update_trend
    redirect_to people_url, :notice => "Successfully destroyed measure."
  end

  def update_trend
    Measure.update_trend
    redirect_to people_url, :notice => "Successfully updated trends."
  end
end
