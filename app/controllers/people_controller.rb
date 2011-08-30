class PeopleController < ApplicationController
# before_filter :authenticate_person!
  skip_before_filter :authenticate_person!, :only => [:view]

  def index
    @people = Person.all
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
  end

  def edit
    @person = current_person
  end

  def update
    @person = current_person
    if @person.update_attributes(params[:person])
      redirect_to :controller=>'measures', :action=>'update_trend', :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end
end
