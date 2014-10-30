class InvitationPage < SitePrism::Page
  set_url '/'
  set_url_matcher /\d+\/invitations\/new/

  element :flash_success, ".flash-success"
  element :flash_notice,  ".flash-notice"
  element :send_invite, "input[type='submit']"
  element :delete_invite_link, "a[data-method='delete'][title='Decline']"

  def delete_invite
    delete_invite_link.click
    page.driver.browser.switch_to.alert.accept
  end
end
