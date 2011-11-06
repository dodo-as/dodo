class UserNotifier < ActionMailer::Base
  default :from => "noreply@freecode.no"
  
    def send_mail(user)
        @user = user
        mail(:to => user.email, :subject => "Registration notification")
  end
end
