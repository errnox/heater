module OrganizationsHelper
  def urlify(string)
    string.gsub(/ /, '-')
  end
end
