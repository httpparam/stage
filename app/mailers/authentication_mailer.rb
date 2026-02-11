class AuthenticationMailer < ApplicationMailer
  default from: "no-reply@stage.app"

  def login_otp(email, otp_code)
    @email = email
    @otp_code = otp_code

    mail(
      to: email,
      subject: "Your sign-in code for Stage"
    )
  end
end
