class AddScoresToTweets < ActiveRecord::Migration
  def change
  	add_column :tweets, :approp_score, :decimal
  end
end
