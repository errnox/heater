class Event < ActiveRecord::Base
  validates :name, :presence => true, :length => { :in => 1..80 }
  validates :description, :length => { :in => 0..10000 }
  validates :annotation, :length => { :in => 0..10000 }
end
