class AddCrowdflowersToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :crowdflower, :boolean
  end
end
