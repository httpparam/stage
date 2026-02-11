class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@stage.app"
  layout "mailer"
end
