
require 'open-uri'

module GitHub

  class RepoInfo

    attr_reader :name
    attr_reader :created
    attr_reader :language
    attr_reader :url
    
    def initialize( from )
      @name     = from['name']
      @created  = DateTime.parse( from['created_at'] )
      @language = from['language']
      @url      = from['html_url']      
    end

    def <=>(o)
      @name <=> o.name
    end
  end

  class UserInfo

    attr_reader :uname
    attr_reader :joined
    attr_reader :url

    def exists?
      @exists
    end

    def initialize( name, exists = false, from_json = nil )

      @uname  = name
      @exists = exists

      if exists

        data = JSON.parse( from_json ) 

        @joined = DateTime.parse( data['created_at'] )
        @url    = data[ 'url' ]
        #puts data.to_yaml
      end 
    end

    def repos
      return @repo_list if @repo_list

      gh_repos = GitHub.get_user_repos(uname)

      puts gh_repos.to_yaml

      @repo_list = gh_repos.map { |r| RepoInfo.new(r) } 
    end

    def language_stats
      return @language_stats if @language_stats

      repo_by_lang = {}
      repos.each do |r|
        repo_by_lang[ r.language ] ||= []
        repo_by_lang[ r.language ] << r
      end

      @language_stats = []
      repo_by_lang.each do |lang, repo_list|
        @language_stats << { name: lang, repos: repo_list.sort }
      end

      @language_stats.sort! { |a, b| b[:repos].count <=> a[:repos].count }

      @language_stats
    end

    def self.does_not_exist
      new :does_not_exist
    end
  end
  
  extend self

  BASE_URL = 'https://api.github.com'

  def get_user(uname)
    return nil if (uname || '').empty?

    UserInfo.new uname, true, get( "/users/#{uname}" )

  rescue OpenURI::HTTPError
    UserInfo.new uname
  end

  def get_user_repos(uname)
    return nil if (uname || '').empty?

    JSON.parse get( "/users/#{uname}/repos" )

  rescue OpenURI::HTTPError
    []
  end

  private

  def get(path)
    url = "#{BASE_URL}#{path}"
    Rails.logger.info "github: GET #{url}"
    open( url ).read
  end

end

