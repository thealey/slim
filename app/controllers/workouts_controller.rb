class WorkoutsController < ApplicationController
  # GET /workouts
  # GET /workouts.json
  def index
    @person = Person.find params[:person_id]

    all_workout_days = @person.all_workout_days(@person.first_workout_date)
    @workouts = Kaminari.paginate_array(all_workout_days[:workouts]).page(params[:page]).per(40)
    @scores = all_workout_days[:scores]
    @against_goal = all_workout_days[:against_goal]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workouts }
    end
  end

  # GET /workouts/1
  # GET /workouts/1.json
  def show
    @workout = Workout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workout }
    end
  end

def clone
  recent_workout = Workout.find(params[:id])
  new_workout = Workout.new
  new_workout.person_id = current_person.id
  new_workout.rating = recent_workout.rating
  new_workout.description = recent_workout.description
  new_workout.workout_date = Time.now
  new_workout.save
  redirect_to overview_person_path(current_person), notice: 'Workout was successfully cloned.'
end

  def new
    @workout = Workout.new
    @recent_workouts = Workout.where(:person_id => current_person.id).order('workout_date desc').limit(10)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workout }
    end
  end

  # GET /workouts/1/edit
  def edit
    @workout = Workout.find(params[:id])
  end

  # POST /workouts
  # POST /workouts.json
  def create
    @workout = Workout.new(params[:workout])
    @workout.person_id = current_person.id

    respond_to do |format|
      if @workout.save
        format.html { redirect_to overview_person_path(@workout.person), notice: 'Workout was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /workouts/1
  # PUT /workouts/1.json
  def update
    @workout = Workout.find(params[:id])

    respond_to do |format|
      if @workout.update_attributes(params[:workout])
        format.html { redirect_to @workout, notice: 'Workout was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workouts/1
  # DELETE /workouts/1.json
  def destroy
    @workout = Workout.find(params[:id])
    @workout.destroy

    respond_to do |format|
      format.html { redirect_to workouts_url }
      format.json { head :no_content }
    end
  end
end
