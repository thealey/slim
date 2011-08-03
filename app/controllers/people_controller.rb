class PeopleController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :index]

  def index
    @people = Person.all
  end
  
  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      session[:person_id] = @person.id
      redirect_to root_url, :notice => "Thank you for signing up! You are now logged in."
    else
      render :action => 'new'
    end
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
