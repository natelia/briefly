require "test_helper"

class SettingTest < ActiveSupport::TestCase
  teardown { Setting.llm_api_key = nil }

  test "stores and clears the api key" do
    Setting.llm_api_key = "sk-test-123"

    assert_equal "sk-test-123", Setting.llm_api_key

    Setting.llm_api_key = nil
    assert_nil Setting.llm_api_key
  end

  test "blank writes clear the key instead of storing empty strings" do
    Setting.llm_api_key = "sk-test-123"
    Setting.llm_api_key = "   "

    assert_nil Setting.llm_api_key
  end

  test "overwrites in a single row" do
    Setting.llm_api_key = "sk-one"
    Setting.llm_api_key = "sk-two"

    assert_equal 1, Setting.count
    assert_equal "sk-two", Setting.llm_api_key
  end
end
