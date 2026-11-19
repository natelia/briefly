require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  teardown { Setting.llm_api_key = nil }

  test "shows the no-key state" do
    old = ENV.delete("LLM_API_KEY")
    Setting.llm_api_key = nil

    get settings_path
    assert_response :success
    assert_select "p", text: /no key set/
  ensure
    ENV["LLM_API_KEY"] = old
  end

  test "saving a key stores it and shows the masked state" do
    patch settings_path, params: { api_key: "sk-from-the-form" }

    assert_redirected_to settings_path
    follow_redirect!
    assert_equal "sk-from-the-form", Setting.llm_api_key
    assert_select "p", text: /key saved, ends with/
  end

  test "removing the key clears it" do
    Setting.llm_api_key = "sk-temp"

    delete settings_path

    assert_redirected_to settings_path
    assert_nil Setting.llm_api_key
  end

  test "the briefing footer links to the settings page" do
    create(:briefing, date: Date.current)

    get root_path
    assert_select "a[href=?]", settings_path, text: "api key"
  end
end
