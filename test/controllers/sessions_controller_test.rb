require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions_new_url
    assert_response :success
  end

  test "should get send_otp" do
    get sessions_send_otp_url
    assert_response :success
  end

  test "should get verify" do
    get sessions_verify_url
    assert_response :success
  end

  test "should get confirm_otp" do
    get sessions_confirm_otp_url
    assert_response :success
  end
end
