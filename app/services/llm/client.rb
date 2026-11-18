require "net/http"

module Llm
  # Thin chat-completions client for the GLM API (OpenAI-compatible
  # endpoint). Same conventions as Briefly::Feed: plain Net::HTTP, an
  # injected post callable for tests, failures raised as Error.
  class Client
    class Error < StandardError; end

    URL = URI("https://open.bigmodel.cn/api/paas/v4/chat/completions")
    MODEL = "glm-4-flash-250414"
    TIMEOUT = 30

    # Returns the assistant message text.
    def self.complete(prompt, model: MODEL, post: ->(body) { post!(body) })
      body = { model:, messages: [ { role: "user", content: prompt } ],
               temperature: 0.3 }.to_json
      raw = post.call(body)
      content = JSON.parse(raw).dig("choices", 0, "message", "content")
      raise Error, "no content in the LLM response" if content.blank?

      content
    rescue JSON::ParserError => e
      raise Error, "bad JSON from the LLM: #{e.message}"
    end

    def self.post!(body)
      http = Net::HTTP.new(URL.host, URL.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = TIMEOUT

      request = Net::HTTP::Post.new(URL, "Content-Type" => "application/json",
                                              "Authorization" => "Bearer #{api_key}")
      response = http.request(request, body)
      raise Error, "HTTP #{response.code} from the LLM" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def self.api_key
      ENV["LLM_API_KEY"] || Rails.application.credentials.dig(:llm, :api_key) ||
        raise(Error, "set LLM_API_KEY or credentials llm.api_key")
    end
  end
end
