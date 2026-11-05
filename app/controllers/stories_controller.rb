class StoriesController < ApplicationController
  def show
    @story = Story.find(params[:id])
  end

  def mark_read
    @story = Story.find(params[:id])
    @story.mark_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to story_path(@story), status: :see_other }
    end
  end

  def mark_unread
    @story = Story.find(params[:id])
    @story.mark_unread!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to story_path(@story), status: :see_other }
    end
  end
end
