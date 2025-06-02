require "test_helper"

class FeedbackDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get feedback_details_new_url
    assert_response :success
  end

  test "should get create" do
    get feedback_details_create_url
    assert_response :success
  end
end
