class Metric < ActiveRecord::Base
  validates :name, :presence => true, :length => { :in => 1..80 }
  validates :description,:length => { :in => 1..10000 }
  validates :rank, :presence => true
  validates :value, :presence => true
  validates :event_id, :presence => true
end
