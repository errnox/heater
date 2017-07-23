require 'spec_helper'

describe User do
  it "creates a new user" do
    new_user_name = 'newuser'
    new_user_email = 'newuser@example.com'
    new_user_password = 'password'
    new_user_salt = 'salt'
    new_user = User.create(:name => new_user_name,
                           :email => new_user_email,
                           :password => new_user_password,
                           :salt => new_user_salt)
    new_user.save
    expect(User.find_by_name(new_user_name).name).to eq(new_user_name)
  end

  it "finds a user by name" do
    user_name = 'red'
    user = User.find_by_name user_name
    expect(user.name).to eq(user_name)
  end

  it "finds a user by email" do
    user_email = 'red@example.com'
    user = User.find_by_email user_email
    expect(user.email).to eq(user_email)
  end
end
