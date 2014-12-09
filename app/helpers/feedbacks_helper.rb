module FeedbacksHelper

  def feedback_priorities
    [ ["1 - Top priority", 1], ["2 - 2nd priority", 2], ["3 - 3rd priority", 3], ["4 - 4th priority", 4] ]
  end

  #TODO: write tests
  def open_requests(user)

    invitations = []
    Invitation.includes(:review).each do |invitation|
      if invitation.sent_to?(current_user) and !invitation.feedback
        invitations << invitation
      end
      if extra_email = AdditionalEmail.find_by_email(invitation.email)
        if User.find(extra_email.user_id) == current_user
          invitations << invitation
        end
      end
    end

    user.feedbacks.where("submitted = ?", false).count + invitations.count
  end

end
