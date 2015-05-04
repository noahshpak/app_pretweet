class Tweet < ActiveRecord::Base
	belongs_to :user
	validates :body, length: { maximum: 120 }, :format => { :without => /[\r\n\n]/, 
    :message => "Please don't press enter (no newline characters)" }
	

end
