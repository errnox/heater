require 'digest/sha1'

class User < ActiveRecord::Base
  before_save :encrypt_password
  after_save :clear_password

  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
  validates :name, :presence => true, :uniqueness => true, :length =>
    { :in => 3..20 }
  validates :email, :presence => true, :uniqueness => true, :format =>
    EMAIL_REGEX
  validates :password, :presence => true, :confirmation => true
  validates_length_of :password, :in => 6..20, :on => :create

  def encrypt_password
    unless password.blank?
      self.salt = Digest::SHA1.hexdigest("#{self.email}#{Time.now}")
      self.password =
        Digest::SHA1.hexdigest("#{self.salt}#{self.password}")
    end
  end

  def clear_password
    self.password = nil
  end

  def self.authenticate(name_or_email="", password="")
    if EMAIL_REGEX.match name_or_email
      user = User.find_by_email name_or_email
    else
      user = User.find_by_name name_or_email
    end
    if user && user.match_password(password)
      return user
    else
      return false
    end
  end

  def match_password(password)
    self.password == Digest::SHA1.hexdigest("#{self.salt}#{password}")
  end
end
