class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    favorites = current_user.favorites.map(&:book_listing_id)
    render json: favorites
  end

  def create
    favorite = current_user.favorites.find_or_create_by(book_listing_id: params[:book_listing_id])
    render json: favorite, status: :created
  end

  def destroy
    favorite = current_user.favorites.find_by(book_listing_id: params[:id])
    if favorite
      favorite.destroy
      render json: { message: "Removido dos favoritos" }, status: :ok
    else
      render json: { error: "Favorito não encontrado" }, status: :not_found
    end
  end
end