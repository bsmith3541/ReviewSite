class PasswordResetPage < SitePrism::Page
  set_url '/password_resets/new'
  set_url_matcher /passwords_resets\/new/

  element :full_title, "title"
  element :heading, "h1", text: "Reset Password"
  element :email_field, "input#email"
  element :request_button, "div.actions input[value='Request Password Reset']"
  element :flash_message, ".flash"
  element :error_message, "section.flash-alert"
  section :okta_form, OktaSection, "section#okta-input"

  def submit_email(email)
    email_field.set(email)
    request_button.click
    if email.empty?
      PasswordResetPage.new
    else
      SignInPage.new
    end
  end

  def change_okta_user(okta_name)
    okta_form.change_okta_user(okta_name)
  end

  def has_flash_error_message?
    error_message ? true : false
  end
end
