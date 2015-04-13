require 'test_helper'

class CrowdflowersControllerTest < ActionController::TestCase
  test "should get crowdsource" do
    get :crowdsource
    assert_response :success
  end

  test "should get create_job" do
    get :create_job
    assert_response :success
  end

  test "should get get_scores" do
    get :get_scores
    assert_response :success
  end

end
