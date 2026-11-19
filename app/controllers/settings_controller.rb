class SettingsController < ApplicationController
  def show
  end

  def update
    Setting.llm_api_key = params[:api_key]
    redirect_to settings_path, notice: "API key saved."
  end

  def destroy
    Setting.llm_api_key = nil
    redirect_to settings_path, notice: "API key removed."
  end
end
