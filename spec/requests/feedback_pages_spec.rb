require 'spec_helper'

describe "Feedback pages", :type => :feature do
  let(:ac_user) { FactoryGirl.create(:user) }
  let(:ac) { FactoryGirl.create(:associate_consultant, :user => ac_user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin_user) }
  let(:review) { FactoryGirl.create(:review, associate_consultant: ac) }
  let(:feedback) { FactoryGirl.create(:feedback, review: review, user: user) }
  let(:inputs) { {
    'feedback_comments' => 'My Comments'
  } }

  subject { page }

  describe "'Create New Feedback' page" do
    before do
      @current_ac = FactoryGirl.create(:associate_consultant)
      @current_review = FactoryGirl.create(:review, :associate_consultant => @current_ac)
      @new_user = FactoryGirl.create(:user)
      @invitation = FactoryGirl.create(:invitation, :email => @new_user.email, :review => @current_review)
    end

    context "when no previous feedback exists", js: true do
      before do
        sign_in @new_user
        visit new_review_feedback_path(@current_review)
        page.find("#ui-accordion-accordion-header-9").click

        inputs.each do |field, value|
          fill_in field, with: value
        end
      end

      it "saves as draft when 'Save Feedback' is clicked" do
        page.execute_script(' $("#save-feedback-button").click(); ')
        page.should have_selector(".flash")
        feedback = Feedback.last
        feedback.submitted.should be_false

        inputs.each do |field, value|
          model_attr = field[9..-1]
          feedback.send(model_attr).should == value
        end
      end

      it "redirects to the preview page when 'Review & Submit' is clicked" do
        # binding.pry
        # page.execute_script(' $("#preview-and-submit-button").click(); ')
        click_button("Preview & Submit")
        current_path.should == preview_review_feedback_path(review, feedback)
      end
    end
  end

  describe "'Preview and Submit Feedback' page" do
    let!(:new_user) { FactoryGirl.create(:user) }
    let(:ac) { FactoryGirl.create(:associate_consultant, user: new_user) }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:review) { FactoryGirl.create(:review, associate_consultant: ac) }
    let(:feedback) { FactoryGirl.create(:feedback, review: review, user: user) }

    before do
      sign_in new_user
      visit new_review_feedback_path(review)
      page.find("#ui-accordion-accordion-header-9").click

      inputs.each do |field, value|
        fill_in field, with: value
      end
    end

    it "saves as final and sends email when 'Submit Final' is clicked", js: true do
      ActionMailer::Base.deliveries.clear

      page.evaluate_script('window.confirm = function() { return true; }')
      page.execute_script(' $("#submit-final-button").click(); ')
      page.should have_selector(".flash")

      feedback = Feedback.last
      current_path.should == review_feedback_path(review, feedback)
      feedback.submitted.should be_true

      inputs.each do |field, value|
        model_attr = field[9..-1]
        feedback.send(model_attr).should == value
      end

      ActionMailer::Base.deliveries.length.should == 2
      mail = ActionMailer::Base.deliveries.first
      mail.to.should == [@current_ac.user.email]
      mail.subject.should == "[ReviewSite] You have new feedback from #{feedback.user}"
    end

  end

  describe "'Edit Feedback' page" do
    let(:feedback) { FactoryGirl.create(:feedback, review: review, user: user) }

    describe "as feedback owner" do
      before do
        sign_in user
      end

      describe "if feedback has been saved as draft" do
        before do
          inputs.each do |field, value|
            model_attr = field[9..-1]
            feedback.update_attribute(model_attr, value)
          end
          visit edit_review_feedback_path(review, feedback)
        end

        it "reloads saved feedback" do
          inputs.each do |field, value|
            if ['feedback_project_worked_on', 'feedback_role_description'].include?(field)
              page.should have_field(field, with: value)
            else
              page.should have_selector('#'+field, text: value)
            end
          end
        end

        it "saves as draft if 'Save Feedback' is clicked" do
          inputs.each do |field, value|
            fill_in field, with: ""
          end

          page.find("#save-feedback-button").click
          feedback = Feedback.last
          current_path.should == edit_review_feedback_path(review, feedback)
          feedback.submitted.should be_false

          inputs.each do |field, value|
            model_attr = field[9..-1]
            feedback.send(model_attr).should == ""
          end
        end
      end

      describe "if feedback has been submitted" do
        before do
          feedback.update_attribute(:submitted, true)
          visit edit_review_feedback_path(review, feedback)
        end

        it "should redirect to homepage" do
          current_path.should == root_path
          page.should have_selector('.flash-alert', text:"You are not authorized to access this page.")
        end
      end
    end

    describe "as other user" do
      before do
        sign_in FactoryGirl.create(:user)
        visit edit_review_feedback_path(review, feedback)
      end

      it "should redirect to homepage" do
        current_path.should == root_path
        page.should have_selector('.flash-alert', text:"You are not authorized to access this page.")
      end
    end
  end

  describe "'Give External Feedback' page" do
    before do
      sign_in ac_user
      visit additional_review_feedback_path(review)
      fill_in "feedback_user_string", with: "A non-user"
    end

    it "saves as draft if 'Save Feedback' is clicked" do
      page.find('h3', text: "Comments").click

      inputs.each do |field, value|
        fill_in field, with: value
      end

      page.find("#save-feedback-button").click
      feedback = Feedback.last
      current_path.should == edit_review_feedback_path(review, feedback)
      feedback.submitted.should be_false
      feedback.user_string.should == "A non-user"
      inputs.each do |field, value|
        model_attr = field[9..-1]
        feedback.send(model_attr).should == value
      end
    end

    it "saves as final and sends email if 'Submit Final' is clicked", js: true do
      page.find("#ui-accordion-accordion-header-9").click

      inputs.each do |field, value|
        fill_in field, with: value
      end

      ActionMailer::Base.deliveries.clear

      page.evaluate_script('window.confirm = function() { return true; }')
      page.execute_script(' $("#submit-final-button").click(); ')
      page.should have_selector(".flash")

      feedback = Feedback.last
      current_path.should == review_feedback_path(review, feedback)
      feedback.submitted.should be_true
      feedback.user_string.should == "A non-user"
      inputs.each do |field, value|
        model_attr = field[9..-1]
        feedback.send(model_attr).should == value
      end

      ActionMailer::Base.deliveries.length.should == 2
      mail = ActionMailer::Base.deliveries.first
      mail.to.should == [ac.user.email]
      mail.subject.should == "[ReviewSite] You have new feedback from #{feedback.user}"
    end
  end

  describe "'Show Completed Feedback' page" do
    let(:feedback) { FactoryGirl.create(:feedback, review: review, user: user) }

    before do
      inputs.each do |field, value|
        model_attr = field[9..-1]
        feedback.update_attribute(model_attr, value)
      end
    end

    describe "unsubmitted feedback" do
      describe "as feedback owner" do
        before do
          sign_in user
          visit review_feedback_path(review, feedback)
        end

        it "displays feedback information" do
          page.should have_selector("h2", text: ac.user.name)
          page.should have_selector("h2", text: review.review_type)
          page.should have_content(user.name)
          inputs.values.each do |value|
            page.should have_content(value)
          end
        end

        it "links to edit page" do
          click_link "Edit"
          current_path.should == edit_review_feedback_path(review, feedback)
        end
      end

      describe "as an admin" do
        before do
          sign_in admin
          visit review_feedback_path(review, feedback)
        end

        it "redirects to homepage" do
          current_path.should == root_path
          page.should have_selector('.flash-alert', text:"You are not authorized to access this page.")
        end
      end
    end

    describe "submitted feedback" do
      before do
        feedback.update_attribute(:submitted, true)
      end

      describe "as the feedback owner" do
        before do
          sign_in user
          visit review_feedback_path(review, feedback)
        end

        it "displays feedback information with no 'Edit' link" do
          page.should have_selector("h2", text: ac.user.name)
          page.should have_selector("h2", text: review.review_type)
          page.should have_content(user.name)
          inputs.values.each do |value|
            page.should have_content(value)
          end

          page.should_not have_selector("a", text: "Edit")
        end
      end

      describe "as an admin" do
        before do
          sign_in admin
          visit review_feedback_path(review, feedback)
        end

        it "displays feedback information" do
          page.should have_selector("h2", text: ac.user.name)
          page.should have_selector("h2", text: review.review_type)
          page.should have_content(user.name)
          inputs.values.each do |value|
            page.should have_content(value)
          end
        end
      end

      describe "as the associate consultant" do
        before do
          sign_in ac_user
          visit review_feedback_path(review, feedback)
        end

        it "displays feedback information with no 'Edit' link" do
          page.should have_selector("h2", text: review.review_type)
          page.should have_content(user.name)
          inputs.values.each do |value|
            page.should have_content(value)
          end

          page.should_not have_selector("a", text: "Edit")
        end
      end

      describe "as another user" do
        before do
          sign_in FactoryGirl.create(:user)
          visit review_feedback_path(review, feedback)
        end

        it "redirects to homepage" do
          current_path.should == root_path
          page.should have_selector('.flash-alert', text:"You are not authorized to access this page.")
        end
      end
    end
  end

end
