class PeopleController < ApplicationController
# before_filter :authenticate_person!
  skip_before_filter :authenticate_person!, :only => [:view]

  def index
    @people = Person.all
  end

  def rss
    @person = Person.find params[:id]
    @reports = @person.progress_report
    @measures = @person.get_measures(7)

    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      #session[:person_id] = @person.id
      redirect_to root_url, :notice => "Thank you for signing up! You are now logged in."
    else
      render :action => 'new'
    end
  end

  def show
    @person = Person.find(params[:id])
    @measures = @person.measures.order('measure_date desc').paginate :per_page=> (@person.measures_to_show || 7), :page => params[:page]

    if @person.nil?
      redirect_to root_url, :notice=>'?'
    else
      render
    end
  end

  def dashboard
    @person = Person.find(params[:id])
    render :layout => 'mobile'
  end

  def edit
    @person = current_person
  end

  def update
    @person = current_person
    if @person.update_attributes(params[:person])
      redirect_to root_url, :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end
end
