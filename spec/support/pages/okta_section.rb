class OktaSection < SitePrism::Section
  element :okta_field, "#temp-okta"
  element :change_user_button, "[value='Change User']"

  def change_okta_user(okta_name)
    okta_field.set(okta_name)
    change_user_button.click
  end
end
