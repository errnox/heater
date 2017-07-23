class TeamMembership < ActiveRecord::Base
  validates_uniqueness_of :team_id, :scope => :user_id
end
