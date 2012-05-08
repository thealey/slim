class Post < ActiveRecord::Base
  attr_accessible :name, :body, :person_id, :start_date, :end_date

  belongs_to :person
  validates_presence_of :person, :name, :body, :start_date, :end_date

end
