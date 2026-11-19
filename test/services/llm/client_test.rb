require "test_helper"

class Llm::ClientTest < ActiveSupport::TestCase
  test "returns the assistant message text" do
    body = nil
    post = ->(b) { body = b; JSON.generate(choices: [ { message: { content: "Hello." } } ]) }

    assert_equal "Hello.", Llm::Client.complete("Say hi", post:)

    payload = JSON.parse(body)
    assert_equal "glm-5.3-flash", payload["model"]
    assert_equal "Say hi", payload.dig("messages", 0, "content")
  end

  test "raises Error when the response has no content" do
    post = ->(_body) { JSON.generate(choices: []) }

    assert_raises(Llm::Client::Error) { Llm::Client.complete("Hi", post:) }
  end

  test "raises Error on bad JSON" do
    post = ->(_body) { "<html>not json</html>" }

    error = assert_raises(Llm::Client::Error) { Llm::Client.complete("Hi", post:) }
    assert_match "bad JSON", error.message
  end

  test "api_key prefers the in-app key over the server env" do
    old = ENV.delete("LLM_API_KEY")
    Setting.llm_api_key = "sk-in-app"
    ENV["LLM_API_KEY"] = "sk-server"

    assert_equal "sk-in-app", Llm::Client.api_key
  ensure
    Setting.llm_api_key = nil
    ENV["LLM_API_KEY"] = old
  end

  test "api_key falls back to the server env without an in-app key" do
    old = ENV.delete("LLM_API_KEY")
    Setting.llm_api_key = nil
    ENV["LLM_API_KEY"] = "sk-server"

    assert_equal "sk-server", Llm::Client.api_key
  ensure
    Setting.llm_api_key = nil
    ENV["LLM_API_KEY"] = old
  end

  test "api_key raises a plain instruction when nothing is set" do
    old = ENV.delete("LLM_API_KEY")
    Setting.llm_api_key = nil

    error = assert_raises(Llm::Client::Error) { Llm::Client.api_key }
    assert_match "Settings", error.message
  ensure
    ENV["LLM_API_KEY"] = old
  end
end
