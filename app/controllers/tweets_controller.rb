require 'rubygems'
require 'crowdflower'
require 'json'
require 'sinatra'


class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]
  # GET /tweets
  # GET /tweets.json
  

   # GET /tweets/first
  def first
    @tweet = Tweet.first
  end 
  
  def last
    @tweet = Tweet.last
  end
  
  def order_author
    @tweets = Tweet.order(:author)
  end
  
  def order_approp
     @tweets = Tweet.order(:approp_score)
  end
  # GET /tweets
  # GET /tweets.json
 
  def index
    @tweets = Tweet.order(:approp_score)
  end

  def new_crowdflower
    @tweet = Tweet.new
    @tweet.crowdflower = true
  end
 


  # GET /tweets/1
  # GET /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets
  # POST /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)
    #add validation for 120 chars
    respond_to do |format|
      if @tweet.save
        format.html { redirect_to @tweet, notice: 'Tweet was successfully created.' }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1
  # PATCH/PUT /tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to @tweet, notice: 'Tweet was successfully updated.' }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  def destroy
    @tweet.destroy
    respond_to do |format|
      format.html { redirect_to tweets_url, notice: 'Tweet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def crowdsource
    @tweets = Tweet.all
    render template: "tweets/crowdsource.html.erb"
    #add crowdflower stuff
    #add some way for users to select the right tweets
    #then add route same way as first, last (above)
    #then display --think about another controller?
  end

  def run_crowdsource
    #add some loading animation...
    @tweets = Tweet.all
    #render template: "tweets/crowdsource.html.erb"
    Tweet.run_crowdsource
    render template: "tweets/results.html.erb"
  end
  def results
    @tweets = Tweet.all
    render template: '/tweets/results.html.erb' 

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tweet_params
      params.require(:tweet).permit(:author, :body)
    end
end
