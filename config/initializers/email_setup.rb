ActionMailer::Base.smtp_settings = {
    :address => "",
    :port => 25,
    :user_name => "",
    :domain => "",
    :password => "",
    :authentication => "plain",
    :enable_starttls_auto => true
}

ActionMailer::Base.raise_delivery_errors = true
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
