class Post < ActiveRecord::Base
  attr_accessible :name, :body, :person_id

  belongs_to :person
  validates_presence_of :person, :name, :body

end
