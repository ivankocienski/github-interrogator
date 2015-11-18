require 'spec_helper'

describe GitHub do

  describe '#get_user' do
    it 'returns nil if nil is sent in as a name' do
      gu = GitHub.get_user( nil )
      expect( gu ).to be nil
    end

    it 'gets the right content' do
      expect( GitHub ).to receive( :get ).with( '/users/username' ).and_return( '{}' )
      GitHub.get_user( 'username' ) 
    end

    it 'returns an info object' do
      allow( GitHub ).to receive( :get ).and_return( '{}' )
      gu = GitHub.get_user( 'username' ) 
      expect( gu.class ).to be GitHub::UserInfo
    end

    it 'returns an info object even if user cannot be found' do
      allow( GitHub ).to receive( :get ).and_raise( OpenURI::HTTPError.new( '', nil ) )

      expect {
        gu = GitHub.get_user( 'username' ) 
        expect( gu.class ).to be GitHub::UserInfo
      }.not_to raise_exception
    end

  end # describe #get_user

  describe '#get_user_repos' do
    it 'returns nil if nil is sent in as a name' do
      gur = GitHub.get_user_repos( nil )
      expect( gur ).to be nil
    end

    it 'gets the right content' do
      expect( GitHub ).to receive( :get ).with( '/users/username/repos' ).and_return( '{}' )
      GitHub.get_user_repos( 'username' ) 
    end

    it 'returns an array' do
      allow( GitHub ).to receive( :get ).and_return( '[]' )
      gur = GitHub.get_user_repos( 'username' ) 
      expect( gur.class ).to be Array
    end

    it 'returns an info object even if user cannot be found' do
      allow( GitHub ).to receive( :get ).and_raise( OpenURI::HTTPError.new( '', nil ) )

      expect {
        gur = GitHub.get_user_repos( 'username' ) 
        expect( gur ).to eq []
      }.not_to raise_exception
    end
  end # describe #get_user_repos

  describe '#get' do
  end # describe #get

end
