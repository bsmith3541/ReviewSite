class FeedbackPage < SitePrism::Page
  set_url '/feedback'

  element :full_title, "title"
  element :submit_final_button, "input#submit-final-button"
  element :save_feedback_button, "input#save-feedback-button"
  element :comments_header_link, "h3", text: "Comments"
  element :flash_message, ".flash"
  element :error_message, ".flash-alert",
    text: "You are not authorized to access this page."
  element :edit_link, "a", text: "Edit"
  element :general_comments_section, "#ui-accordion-accordion-header-9"
end
