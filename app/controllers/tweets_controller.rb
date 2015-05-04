require 'rubygems'
require 'crowdflower'
require 'json'
require 'sinatra'


class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]
  # GET /tweets
  # GET /tweets.json
  

   # GET /tweets/first
  API_KEY = "7j-9LVUMR2w9kyGPNu_B"
  DOMAIN_BASE = "https://api.crowdflower.com"
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
    CrowdFlower::Job.connect! API_KEY, DOMAIN_BASE
    job = CrowdFlower::Job.create("Crowdsource Tweets")
    @tweets.each_with_index do |tweet| 
      unit = CrowdFlower::Unit.new(job)
      unit.create("id" => index, "content"=>tweet.body) 
    end
    hit_in_cml = '
    <h4>Read the text below paying close attention to detail:</h4>
    <div class="well">
    {{content}}</div>
    <cml:radios label="How appropriate is this tweet?" name="appropriate" aggregation="agg" validates="required" gold="false" class="">
      <cml:radio label="5: Universally Appropriate" value="yes"/>
      <cml:radio label="4: Mostly Appropriate" value="no"/>
      <cml:radio label="3: Appropriate" value="non_english"/>
      <cml:radio label="2: Mildly Inappropriate" value="mildly inappropriate"/>
      <cml:radio label="1: Inappropriate" value="inappropriate"/>
    </cml:radios>
    <!-- Relevance question ends -->'


    job.update({
    :title => 'Review Tweets for Appropriateness',
    :included_countries => ['US'],  # Limit to the USA and United Kingdom
        # Please note, if you are located in another country and you would like
        # to experiment with the sandbox (internal workers) then you also need
        # to add your own country. Otherwise your submissions as internal worker
        # will be rejected with Error 301 (low quality).
    :payment_cents => 10, # This is how much a contributor gets paid for each task or collection of units on a page.
    :judgments_per_unit => 1,
    :units_per_assignment => Tweet.count, # This is the number of units that a contributor must complete on a page before submitting their answers. 
    :instructions => 'Please read the following tweet and rate the humor level and expected audience',
    :cml => hit_in_cml,
    #:webhook_uri => 'https://secure-cliffs-6566.herokuapp.com/tweets/webhook',
    :explicit_content => false,
    :options => {
        :front_load => 1, # quiz mode = 1; turn off with 0
      }
    })
    #wait for the upload
    #add in loading animation
    # add 'on_demand' for extermal
    job.enable_channels(['cf_internal'])
    while true do
      if job.get["units_count"] == Tweet.count
        order = CrowdFlower::Order.new(job)
        order.debit(Tweet.count, ['cf_internal'])
        break
      end
    end
    respond_to do |format|
      format.html {render :results}
    end
    tweet_bodies = []
    scores = []
    while true do 
      puts job.status["completed_units_estimate"]
      if job.get['completed']
        judgment = CrowdFlower::Judgment.new(job) 
        response = judgment.all
        payload = JSON.parse(response.body)
        for row in payload 
          row[1].each_with_index do |val, index| 
            if val.include? "content"
              tweet_bodies.push(val[1])
            elsif val.include? "appropriate" 
              if val[1].fetch('agg').eql? "yes"
                scores.push(1)
              else 
                scores.push(0)
              end
            end
          end
        end
        puts tweet_bodies
        puts scores
        @tweets.each_with_index do |tweet|
          body = tweet.body
          if body.include? "\n"
            body = body.gsub('\n', '')
          end
          if (tweet_bodies.index(body)) 
            score = scores[tweet_bodies.index(body)]
            tweet.update(approp_score: score)
          else 
            puts "fail"
          end
        end
        break
      else 
        sleep 30
      end
    end
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
