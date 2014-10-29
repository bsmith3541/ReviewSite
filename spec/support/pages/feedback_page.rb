class PasswordResetPage < SitePrism::Page
  set_url '/feedback'
  

  element :full_title, "title"
  element :submit_final_button, "input#submit-final-button"
  element :save_feedback_button, "input#save-feedback-button"
  element :comments_header_link, "h3", text: "Comments"
  element :flash_message, ".flash"
  element :error_message, ".flash-alert",
  element :edit_link, "a", text: "Edit"
    text:"You are not authorized to access this page.")
  section :okta_form, OktaSection, "section#okta-input"
