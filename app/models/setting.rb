# Single-row store for instance settings. The LLM API key lives here
# when the user enters it in the app; a server-set LLM_API_KEY env var
# is the deployment alternative (see Llm::Client.api_key).
class Setting < ApplicationRecord
  def self.llm_api_key
    first&.llm_api_key
  end

  def self.llm_api_key=(value)
    first_or_create.update!(llm_api_key: value.to_s.presence)
  end
end
