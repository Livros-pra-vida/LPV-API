class FavoritesController < ApplicationController
  before_action :authenticate_user!

  # GET /favorites   ids dos anúncios favoritos do usuário
  def index
    render json: current_user.favorites.pluck(:book_listing_id)
  end

  # POST /favorites   corpo: { "book_listing_id": 3 }
  def create
    anuncio = BookListing.find(params.expect(:book_listing_id))
    current_user.favorites.find_or_create_by!(book_listing: anuncio)
    render json: current_user.favorites.pluck(:book_listing_id), status: :created
  rescue ActiveRecord::RecordNotUnique
    render json: current_user.favorites.pluck(:book_listing_id), status: :created
  end

  # DELETE /favorites/:id   (:id = id do anúncio)
  def destroy
    current_user.favorites.where(book_listing_id: params[:id]).destroy_all
    render json: current_user.favorites.pluck(:book_listing_id)
  end
end
