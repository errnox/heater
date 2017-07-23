class OrganizationUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Team.all.each do |team|
      if value == team.name &&
          record.organization_id == team.organization_id
        record.errors[attribute] << (options[:message]) ||
          'is already a team name in this Organization'
      end
    end
  end
end

class Team < ActiveRecord::Base
  validates :name, :presence => true, :length =>
    { :in => 2..80 }, :organization_uniqueness => true, :format =>
    /\A[A-Z0-9 _+@&]*\z/i
  validates :description, :length => { :in => 0..10000 }
end
