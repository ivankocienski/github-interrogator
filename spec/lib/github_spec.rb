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

    let( :path ) { "/thing/to/get" }
    let( :fake_file ) { double read: nil }

    it 'gets the right url from input path' do
      
      expected_url = "#{GitHub::BASE_URL}#{path}"

      expect( GitHub ).to receive( :open ).with( expected_url ).and_return( fake_file )

      GitHub.send :get, path
    end
  end # describe #get

  describe GitHub::RepoInfo do

    let( :response_data ) { 
      JSON.parse(
        File.open( 
          File.join( Rails.root, 'spec/data/github-get-user-repos.json' ))
        .read)
    } 

    context 'initialization' do
      it 'sets up correct info' do
        info = GitHub::RepoInfo.new( response_data.first )
        expect( info.name ).to     eq 'audio-engine'
        expect( info.created ).to  eq DateTime.new( 2015, 1, 5, 11, 4, 43 )
        expect( info.language ).to eq 'C++'
        expect( info.url ).to      eq 'https://github.com/ivankocienski/audio-engine'
      end
    end

    context 'sorting' do

      it 'sorts by name' do
        repos = response_data.
          map { |rd| GitHub::RepoInfo.new(rd)  }.
          sort

        names = repos.map &:name 

        expect( names ).to eq %w{
          Migrator
          Qt-MonthView-Widget
          Site-Builder
          audio-engine
          cubes
          ega
          gdata-tng
          github-interrogator
          graphics
          html-views
          ik-rb-gsl
          json-cxx
          ktracer
          lean-auth
          lhs-bus-times
          lhs-bus-times-2
          netclient
          octave-ruby
          pal-edit
          qt-toggle-input
          rotal
          rsokoban
          ruby-native-ping
          shader
          socket-stuff
          splatman
          tank-command-2000
          text-adventure
          to_nil
          torus
        }

      end
    end
  end

  describe GitHub::UserInfo do

    let( :response_json ) { 
      File.open( 
                File.join( Rails.root, 'spec/data/github-get-user.json' ))
      .read
    }

    context 'initialization' do
      it 'sets up the right fields' do
        info = GitHub::UserInfo.new( 'username', true, response_json )

        expect( info.exists? ).to be true
        expect( info.uname ).to   eq 'username'
        expect( info.joined ).to  eq DateTime.new( 2010, 1, 4, 11, 36, 36 )
      end

      it 'flags does not exist if nil sent in' do
        info = GitHub::UserInfo.new( 'username' )

        expect( info.exists? ).to be false
        expect( info.uname ).to   eq 'username'
      end
    end

    context 'with user repos' do

      let( :user_info ) { GitHub::UserInfo.new( 'username', true, response_json ) }

      before :each do
        json = File.open( 
            File.join( Rails.root, 'spec/data/github-get-user-repos.json' ))
          .read

        fake_file = double( read: json )

        allow( GitHub ).to receive( :open ).and_return( fake_file ) 
      end

      context '#repos' do
        it 'returns array of RepoInfos' do
          repos = user_info.repos

          expect( repos.length ).to eq 30
          expect( repos.first.class ).to eq GitHub::RepoInfo
        end

      end

      context '#language_stats' do
        it 'pulls stats out of repo list' do
          stats = user_info.language_stats

          expect( stats.length ).to eq 5
        end

        it 'sorts by quantity' do
          stats = user_info.language_stats 

          quantities = stats.map { |s| s[:repos].length }

          expect( quantities ).to eq [ 12, 10, 4, 2, 2 ]
        end
      end
    end

  end

end
