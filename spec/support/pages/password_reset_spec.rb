# require 'rails_helper'
require 'spec_helper'

feature 'Password Reset' do

  let(:page) { PasswordResetPage.new }
  let(:user) { FactoryGirl.create(:user,
    password_digest: BCrypt::Password.create("password")) }

  before do
    page.load
  end

  describe "basic page" do
    it "should have the correct title" do
      pry
      page.should have_full_title
      # page.title.should == "Review Site | Request Password Reset"
    end

    it "should have the correct heading" do
      page.should have_heading
    end
  end

  describe "requesting a new password" do
    before do
      page.okta_form.change_okta_user("askjdh")
      page.load
    end

    context "when an invalid email is entered" do
      before do
        @result = page.submit_email("")
      end

      it "should display an error message" do
        @result.should have_flash_error_message
      end
    end

    context "when a valid email is entered" do
      it "should send an email" do
        UserMailer.should_receive(:password_reset).with(user).and_return(double("mailer", :deliver => true))
        page.submit_email(user.email)
      end

      it "should redirect to the sign in page" do
        page.submit_email(user.email)
        @signin = SignInPage.new
        @signin.should be_displayed
        @signin.should have_heading
      end

      it "should display a flash message" do
        @signin = page.submit_email(user.email)
        @signin.should have_notice_message
      end
    end

    context "when the user signs in" do

      let(:signin_page) { SignInPage.new }

      before do
        page.submit_email(user.email)
        @signin = SignInPage.new
      end

      describe "with valid information" do
        it "should retain their original password" do
          result = @signin.log_in(user.email, "password")
          result.should have_selector("h1", text: "Upcoming Reviews")
        end
      end
    end
  end
end
