require "spec_helper"
require "ruby-debug"

module Badgeville

  describe BaseResource, "method errors()" do

    context "the BaseResource (User) already has an associated Badgeville::Errors object" do
      before do
        @mock_user_without_err_obj = User.new
      end
      it "should call the new method for Badgeville::Errors, rather than ActiveResource::Errors" do
        Badgeville::Errors.should_receive( :new )
        @mock_user_without_err_obj.errors
      end
    end

    context "the BaseResource (User) does not yet have an associated Badgeville::Errors object" do
      before do
        @mock_user_with_errors_object = User.new
        @mock_user_with_errors_object.errors.add(:base, "Here is a mock error message string.")
      end
      it "should not call the new method for Badgeville::Errors since an error is already saved" do
        Badgeville::Errors.should_not_receive( :new )
      end

      it "should have the value 'Here is a mock error message string.' saved as an array element" do
         @mock_user_with_errors_object.errors.messages.should == {:base => ["Here is a mock error message string."]}
      end
    end

  end

  describe BaseResource, "method load_remote_errors()" do
      before do
      end
      it do
      end
  end
end