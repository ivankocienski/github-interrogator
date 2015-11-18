class HomeController < ApplicationController
  def index
    @github_username = params[:u]
    @github_info = GitHub.get_user(@github_username)
  end

  def about
  end

end
