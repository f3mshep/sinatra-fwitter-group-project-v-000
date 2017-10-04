require './config/environment'


class ApplicationController < Sinatra::Base

  configure do
  	enable :sessions
  	set :session_secret, "Tony-b4G-a-dOoOoonUt$$$$"
    set :public_folder, 'public'
    set :views, 'app/views'
    register Sinatra::Flash
  end

  get '/' do
    redirect '/tweets' if logged_in?
  	erb :index
  end

  get '/tweets/new' do
    redirect '/login' if !logged_in?
    @user = current_user
    erb :'/tweets/create_tweet'
  end

  get '/tweets/:id' do
    redirect 'login' if !logged_in?
    @tweet = Tweet.find(params[:id].to_i)
    @owned = true if @tweet.user_id == session[:user_id]
    erb :'/tweets/show_tweet'
  end

  get '/tweets/:id/edit' do
    redirect '/login' if !logged_in?
    @tweet = Tweet.find(params[:id].to_i)
    if @tweet.user_id == session[:user_id]
      erb :'/tweets/edit_tweet'
    else
      redirect '/login'
    end
  end

  post "/follow/:id/new" do
    redirect '/login' if !logged_in?
    user = User.find(params[:id].to_i)
    star = User.find(params[:follow].to_i)
    user.follow(star.id)
    flash[:success] = "Now following #{star.username}."
    redirect '/tweets'
  end

  post '/tweets/:id/edit' do
    tweet = Tweet.find(params[:id].to_i)
    if params[:content].empty?
      flash[:error] = "Tweets must have content."
      redirect "/tweets/#{tweet.id}/edit"
    else   
      tweet.update(content: params[:content])
      redirect "/tweets/#{tweet.id}"
    end
  end

  delete '/tweets/:id/delete' do
    tweet = Tweet.find(params[:id].to_i)
    if tweet.user_id == session[:user_id].to_i
      tweet.destroy
      flash[:success] = "Fweet succesfully deleted."
      redirect '/tweets'
    else
      redirect '/tweets'
    end
  end

  get '/signup' do
    redirect '/tweets' if logged_in?
  	erb :'/users/create_user'
  end

  post '/signup' do
    user = User.new(username: params[:username], email: params[:email] , password: params[:password])
    redirect '/signup' if params[:username].empty? || params[:email].empty?
    if user.save
      flash[:success] = "Account created."
      session[:user_id] = user.id
      redirect '/tweets'
    else
      redirect '/signup'
      flash[:error] = "Error creating account."
    end
    
  end

  get '/users/:username' do
    @current_user = current_user
    @user = User.find_by_slug(params[:username])
    @cool_people = User.all - current_user.following
    erb :'/users/show'
  end

  post "/users/:username/new-pic" do
    @user = User.find_by_slug(params[:username])
    @user.update(profile_image: params[:profile_image])
    redirect '/tweets'
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/login' do
    redirect '/tweets' if logged_in?
  	erb :'/users/login'
  end

  post '/tweets/new' do
   if params[:tweet_content].empty?
    flash[:error] = "Fweets must have content."
    redirect '/tweets/new'
   elsif !params[:picture].empty?
    Tweet.create(content: params[:tweet_content], picture: params[:picture], user: current_user)
    redirect '/tweets'
   else
    Tweet.create(content: params[:tweet_content], user: current_user)
    redirect '/tweets'
   end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Welcome, #{user.username}"
      redirect '/tweets'
      #set up flash message to alert user they logged in
    else
      flash[:error] = "Wrong username or password."
      redirect '/login'
      #maybe unhide an element that alerts user they failed??
    end

  end

  get '/users/:slug/followers' do
    
    @user = User.find_by_slug(params[:slug])
    redirect '/login' if !logged_in? || current_user != @user
    @followers = @user.followers
    erb :'/users/followers'
  end

  get '/users/:slug/following' do
    redirect '/login' if !logged_in?
    @user = User.find_by_slug(params[:slug])
    @following = @user.following
    erb :'/users/following'
  end

  post '/users/:user_slug/followers/delete' do
    @user = User.find_by_slug(params[:user_slug])
    @follower = User.find_by_slug(params[:follower])
    redirect '/login' if !logged_in? || current_user != @user
    session[:return_to] = request.referer
    @follower.unfollow(@user)
    flash[:success] = "Removed #{@follower.username}."
    redirect session.delete(:return_to)

  end

  post '/users/:user_slug/following/:delete_slug/delete' do
    user = User.find_by_slug(params[:user_slug])
    delete_me = User.find_by_slug(params[:delete_slug])
    redirect '/tweets' if user != current_user
    session[:return_to] = request.referer
    user.unfollow(delete_me)
    flash[:success] = "Unfollowed #{delete_me.username}."
    redirect session.delete(:return_to)
  end

  get '/tweets' do
    redirect '/login' if !logged_in?
    @user = current_user
    @cool_people = User.all - @user.following
    @tweets = (@user.following.collect {|user|user.tweets } << @user.tweets).flatten
    erb :'/tweets/tweets'
  end

  def logged_in?
    !!session[:user_id]
  end

  def current_user
    User.find(session[:user_id])
  end

end