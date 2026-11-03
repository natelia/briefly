class BriefingsController < ApplicationController
  def show
    @briefing = Briefing.for_date(params[:date] || Date.current)
  end
end
