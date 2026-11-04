class QuizQuestionsController < ApplicationController
  def answer
    @quiz_question = QuizQuestion.find(params[:id])
    @choice = params[:choice].to_i

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to briefing_path(date: @quiz_question.briefing.date) }
    end
  end
end
