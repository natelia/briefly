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
end
