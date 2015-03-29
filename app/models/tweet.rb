class Tweet < ActiveRecord::Base
	belongs_to :user
	def first
    	@tweet = Tweet.first
  	end	
  	def last
   		 @tweet = Tweet.last
  	end
  	def order_author
  		@tweets.order(:author)
  	end
  	def order_approp
  		@twees.order(:approp_score)
  	end


end
