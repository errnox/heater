class Organization < ActiveRecord::Base
  validates :name, :presence => true,:uniqueness =>
    true, :length => { :in => 2..80 }, :format => /\A[A-Z0-9 _+@&]*\z/i
  validates :description, :length => { :in => 0..10000 }
end
