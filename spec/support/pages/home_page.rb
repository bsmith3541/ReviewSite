class HomePage < SitePrism::Page
  set_url '/'
  set_url_matcher /\//

  element :full_title, "title"
  element :new_review_link, "a", text: "New Review"
  element :ask_feedback_link, "a", text: "Ask for Feedback"
  element :submit_feedback_link, "a", text: "Submit Feedback"
  element :ac_reviews_heading, "h1", text: "Your Upcoming Review"
  element :coach_reviews_heading, "h1", text: "Upcoming Reviews"
  element :show_review_link, ".fa-eye"

end
