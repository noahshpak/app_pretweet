class UserMailer < ApplicationMailer
	default from: "pretweetlife@gmail.com"

	def welcome_email(user)
		@user = user
		@url = 'http://www.google.com'
		mail(to: @user.email, subject: 'Welcome Email Test')
	end
end
