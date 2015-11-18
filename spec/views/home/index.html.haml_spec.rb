require 'spec_helper' 

describe 'home/index.html.haml', type: :view do

  context 'input form' do
    it 'is present' do
      render
      xp = "//form[@action='#{root_path}' and @method='get']"
      expect( rendered ).to have_xpath(xp)

      xp = "//input[@type='text' and @name='u']"
      expect( rendered ).to have_xpath(xp)

      expect( rendered ).to have_selector( 'button', text: 'Look up' )
    end

    it 'is filled with @github_username' do
      assign :github_username, 'githubusername'
      assign :github_info, double( exists?: false )
      render

      xp = "//input[@type='text' and @value='githubusername']"
      expect( rendered ).to have_xpath(xp)
    end
  end

  context 'with no username' do
    it 'gives feedback' do
      render
      expect( rendered ).not_to have_selector( 'h1' )
    end
  end

  context 'with username' do
    
    before :each do
      assign :github_username, 'githubusername'
    end

    context 'with non existant user' do
      it 'gives feedback' do
        assign :github_info, double( exists?: false )
        render

        expect( rendered ).to have_content( 'This user could not be found' )
      end
    end

    context 'with existing user' do

      let( :github_info ) {
        json = File.open( 
            File.join( Rails.root, 'spec/data/github-get-user.json' ))
          .read

        GitHub::UserInfo.new( 'githubusername', true, json )
      }

      before :each do
        assign :github_info, github_info
      end

      context 'with no repos' do

        before :each do
          allow( github_info ).to receive( :repos ).and_return( [] )
          render
        end

        it 'has link to user profile' do
          xp = "//h1/a[@href='#{github_info.url}']"
          expect( rendered ).to have_xpath( xp, text: github_info.uname ) 
        end

        it 'has joined info' do
          text = "Joined #{time_ago_in_words( github_info.joined)}"
          expect( rendered ).to have_content( text )
        end
      
        it 'gives feedback' do
          expect( rendered ).to have_content( 'Could not find any repos for this user' )
        end

      end # with no repos

      context 'with repos' do

        let( :repo_data ) {
          JSON.parse(
            File.open( 
              File.join( Rails.root, 'spec/data/github-get-user-repos.json' ))
            .read)
        }
        
        before :each do
          allow( GitHub ).to receive( :get_user_repos ).and_return( repo_data )
          render
        end

        it 'has count overview' do
          expect( rendered ).to have_content( 'Found 30 repos with 5 languages' )
        end

        it 'has titles' do
          expect( rendered ).to have_selector( 'h2', count: 5 )

          xp = "//h2[1]"
          expect( rendered ).to have_xpath( xp, text: 'C++ 12 repos' )
        end

        it 'has repo entries' do
          expect( rendered ).to have_selector( 'ul.repo-info li', count: 30 ) 
        end

        context 'for a repo entry' do
          it 'has repo title and link' do
            repo = github_info.language_stats.first[:repos].first
            xp = "//ul[1]/li[1]/a[@href='#{repo.url}']"
            expect( rendered ).to have_xpath( xp, text: repo.name ) 
          end
        end

      end # with repos

    end # with existing user

  end # with username

end

