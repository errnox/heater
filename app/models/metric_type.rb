class MetricType < ActiveRecord::Base
  validates :name, :presence => true, :length => { :in => 1..80 }
  validates :description, :length => { :in => 1..10000 }
end
