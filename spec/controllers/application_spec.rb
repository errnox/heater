require 'spec_helper'

describe ApplicationController do
  fixtures :users

  before(:each) do
    @user = User.all[0]
  end

  describe 'GET #index' do
    it 'should respond successfully with a HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe '#authenticate_user' do
    it 'should return "true"' do
      session[:user_id] = @user.id
      expect(@controller.send(:authenticate_user)).to eq(true)
    end
  end

  describe '#save_login_state' do
    it 'should return "true"' do
      expect(@controller.send(:save_login_state)).to eq(true)
    end
  end
end
