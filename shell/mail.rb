require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address   => "smtp.gmail.com",
   :port      => 587,
   :domain    => "fabbi.com.vn",
   :authentication => :plain,
   :user_name      => "dungvv@fabbi.com.vn",
   :password       => "seabird123456",
   :enable_starttls_auto => true
}
class Mailer < ActionMailer::Base

  def daily_email
    @var = "var"

    mail(   :to      => "vuvandung085@gmail.com",
            :from    => "hayabusa_dev@ascend-corp.co.jp",
            :subject => "testing mail",
            :body => 'test')
  end
end

email = Mailer.daily_email
puts email
email.deliver
