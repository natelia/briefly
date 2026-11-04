class ConceptCardsController < ApplicationController
  def show
    @concept_card = ConceptCard.find(params[:id])
  end
end
