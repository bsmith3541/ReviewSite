# require 'rails_helper'
require 'spec_helper'

feature 'Password Reset' do

  let(:page) { PasswordResetPage.new }
  let(:user) { FactoryGirl.create(:user,
    password_digest: BCrypt::Password.create("password")) }
  let (:signin_page) { SignInPage.new }

  before do
    page.load
  end

  describe "basic page" do
    it "displays the correct title" do
      # page.should have_full_title
      page.title.should == "Review Site | Request Password Reset"
    end

    it "displays the correct heading" do
      page.should have_heading
    end
  end

  feature "requesting a new password" do
    before do
      page.okta_form.change_okta_user("askjdh")
      page.load
    end

    context "with an invalid email" do
      before do
        @result = page.submit_email("")
      end

      it "displays an error message" do
        @result.should have_flash_error_message
      end
    end

    context "with a valid email" do
      it "sends an email" do
        UserMailer.should_receive(:password_reset).with(user).and_return(double("mailer", :deliver => true))
        page.submit_email(user.email)
      end

      it "redirects to the sign in page" do
        page.submit_email(user.email)
        signin_page.should be_displayed
      end

      it "displays a flash message" do
        page.submit_email(user.email)

        signin_page.should have_notice_message
      end
    end
  end

  context "signing in before changing the password" do
    before do
      page.submit_email(user.email)
      # @signin = SignInPage.new
    end

    describe "with valid information" do
      it "retains the original password" do
        # result = @signin.log_in(user.email, "password")
        result = signin_page.log_in(user.email, "password")
        result.should have_selector("h1", text: "Upcoming Reviews")
      end
    end
  end
end
