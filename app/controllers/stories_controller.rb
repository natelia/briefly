class StoriesController < ApplicationController
  def mark_read
    @story = Story.find(params[:id])
    @story.mark_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  def mark_unread
    @story = Story.find(params[:id])
    @story.mark_unread!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end
