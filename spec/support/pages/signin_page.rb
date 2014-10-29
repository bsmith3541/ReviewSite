class SignInPage < SitePrism::Page
  set_url '/signin'
  set_url_matcher /signin/

  element :heading, "h1", text: "Sign In"
  element :email_field, "input#session_email"
  element :password_field, "input#session_password"
  element :flash_message, ".flash"
  element :notice_message, ".flash.flash-notice"
  section :okta_form, OktaSection, "section#okta-input"
  element :sign_in_button, "input[value='Sign In']"

  def log_in(email, password)
    email_field.set(email)
    password_field.set(password)
    sign_in_button.click
    SignInPage.new
  end

  def submit_email(email)
    email_field.set(email)
    request_button.click
    PasswordResetPage.new
  end

  def change_okta_user(okta_name)
    okta_form.change_okta_user(okta_name)
    SignInPage.new
  end
end
