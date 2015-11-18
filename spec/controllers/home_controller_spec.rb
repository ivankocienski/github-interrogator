require 'spec_helper'

describe HomeController, type: :controller do

  before :each do
    allow( GitHub ).to receive( :get ).and_return( '{}' )
  end

  describe '#index' do
    it 'responds success' do
      get :index
      expect( response ).to be_success 
    end

    it 'sets up @github_username' do
      get :index, { u: 'a-user-name' }
      expect( assigns[:github_username] ).to eq 'a-user-name'
    end

    it 'sets up @github_info' do
      get :index, { u: 'a-user-name' }
      expect( assigns[:github_info].class ).to eq GitHub::UserInfo
    end
    
  end

  describe '#about' do
    it 'responds successfully' do
      get :about
      expect( response ).to be_success
    end
  end

end
