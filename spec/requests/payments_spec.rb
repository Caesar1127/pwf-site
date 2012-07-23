require 'spec_helper'

feature "Process payments for a registration" do

  scenario " Happy day parent registers and pays for registration" do
    @parent = FactoryGirl.create(:complete_parent)
    do_login(@parent)
    do_create_new_student
    click_link "pay_registration"
    current_path.should == new_payment_path
    page.should have_content "Total Amount: $#{@parent.current_unpaid_pending_registrations.count * 50}"
  end

  scenario "Parent renews registration and pays" do
    @parent = FactoryGirl.create(:parent_with_old_student_registrations)
    do_login(@parent)
    @parent.students.each do|student|
      click_link "register_student_#{student.id}"
      do_fillin_registration_fields
      student.reload
    end
    click_link "pay_registration"
    current_path.should == new_payment_path
    page.should have_content "Total Amount: $#{@parent.current_unpaid_pending_registrations.count * 50}"
  end

  scenario "Parent has one new and old registration pays for new registration" do
    @parent = FactoryGirl.create(:parent_with_old_student_registrations)
    do_login(@parent)
    @parent.students.each do|student|
      click_link "register_student_#{student.id}"
      do_fillin_registration_fields
      student.reload
    end
    current_path.should==parent_path(@parent)
    do_create_new_student
    click_link "pay_registration"
    current_path.should == new_payment_path
    page.should have_content "Total Amount: $#{@parent.current_unpaid_pending_registrations.count * 50}"
  end

  scenario "Parent should not be able to pay for past registration" do
    @parent = FactoryGirl.create(:parent_with_old_student_registrations)
    do_login(@parent)
    page.should have_no_selector "pay_registration"
  end

  scenario "Parent with old registrations creates new student registration can pay for new registration only" do
    @parent = FactoryGirl.create(:parent_with_old_student_registrations)
    do_login(@parent)
    do_create_new_student
    click_link "pay_registration"
    current_path.should == new_payment_path
    page.should have_content "Total Amount: $#{50}"
  end

  scenario "Parent should not be able to pay for wait-list registration" do
    season = Season.current
    season.status = "Wait List"
    season.save
    @parent = FactoryGirl.create(:parent_with_current_student_registrations)
    do_login(@parent)
    page.should have_no_selector "pay_registration"
  end

  scenario "Parent should not be able to pay for already paid-for registration" do
    @parent = FactoryGirl.create(:parent_with_current_student_registrations)
    @parent.current_unpaid_pending_registrations.each do|reg|
      reg.status = "Confirmed Paid"
      reg.save
    end

    do_login(@parent)
    page.should have_no_selector "pay_registration"
  end


  scenario "User checks out with card",:js => true  do
    @parent = FactoryGirl.create(:parent_with_current_student_registrations)
    do_login(@parent)
    click_link "pay_registration"
    do_pay_with_card
    assert_message_visible("Payment Transaction Completed")
    current_path.should == payment_path(@parent.payments.last)
    @parent.current_unpaid_pending_registrations.count.should == 0
  end

  scenario "User checks out with paypal", :js => true do
    FakeWeb.allow_net_connect = true
    @browser = page.driver.browser
    visit "https://developer.paypal.com/"
    fill_in "login_email", :with => "herbyraynaud@yahoo.com"
    fill_in "login_password", :with => "cala(G5/$1)pp"
    click_button "Log In"

    @parent = FactoryGirl.create(:parent_with_current_student_registrations)
    do_login(@parent)
    click_link "pay_registration"
    do_pay_with_paypal
    page.should have_content('Choose a way to pay')

    fill_in "login_email", :with => "buyer_1340271608_per@yahoo.com"
    fill_in "login_password", :with => "340370106"
    click_button "Log In"
    page.uncheck("esignOpt")
    page.check("esignOpt")
    click_button "Agree and Continue"
    click_button "Pay Now"
    assert_message_visible("Payment Transaction Completed")
    @parent.current_unpaid_pending_registrations.count.should == 0
  end

  scenario "Parent should only be charged for active registrations",:js => true  do
    @parent = FactoryGirl.create(:parent_with_old_student_registrations)
    do_login(@parent)
    student = @parent.students.first
    click_link "student_id_#{student.id}"
    page.should have_content "Not Registered"
    click_link "new_registration"
    do_fillin_registration_fields
    @parent.reload
    @parent.current_unpaid_pending_registrations.count.should == 1
    click_link "pay_registration"
    do_pay_with_card
    assert_message_visible("Payment Transaction Completed")
    current_path.should == payment_path(@parent.payments.last)
    @parent.current_unpaid_pending_registrations.count.should == 0
  end

end

def assert_message_visible(content)
  wait_until { page.should have_content content }
rescue Capybara::TimeoutError
  "Expected #{content} to be visible."
end
