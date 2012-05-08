class PostsController < ApplicationController

  def index
    @posts = Post.order('created_at desc')
  end

  def show
    @post = Post.find(params[:id])
    @measures = Measure.where('measure_date > ? and measure_date < ?', @post.start_date, @post.end_date) 
  end

  def new
    unless person_signed_in?
      redirect_to :posts, :notice => "You must be logged in."
    end
    @post = Post.new
    @post.start_date = Time.now.to_date - 7.days
    @post.end_date = Time.now.to_date
  end

  def create
    @post = Post.new(params[:post])
    if @post.save
      redirect_to @post, :notice => "Successfully created post."
    else
      render :action => 'new'
    end
  end

  def edit
    @post = Post.find(params[:id])
    unless person_signed_in?
      redirect_to @post, :notice => "You must be logged in."
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      redirect_to @post, :notice  => "Successfully updated post."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    unless person_signed_in?
      redirect_to :posts, :notice => "You must be logged in."
    end
    @post.destroy
    redirect_to posts_url, :notice => "Successfully destroyed post."
  end
end
