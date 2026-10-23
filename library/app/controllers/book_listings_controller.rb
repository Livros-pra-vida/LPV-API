class BookListingsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    @listings = BookListing.order(created_at: :desc)
    render json: @listings
  end

  def create
    listing = current_user.book_listings.build(listing_params)
    if listing.save
      render json: listing, status: :created
    else
      render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Permite ao Admin alterar o destaque (featured) na Home
  def update
    listing = BookListing.find_by(id: params[:id])
    return render json: { error: "Anúncio não encontrado" }, status: :not_found unless listing

    # Se for alteração de destaque, exige permissão de Admin
    if params[:book_listing][:featured] != nil
      return render json: { error: "Apenas administradores podem gerenciar destaques" }, status: :forbidden unless current_user&.admin?
    end

    if listing.update(listing_params)
      render json: listing, status: :ok
    else
      render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    listing = BookListing.find_by(id: params[:id])
    return render json: { error: "Anúncio não encontrado" }, status: :not_found unless listing

    if current_user.admin? || listing.user_id == current_user.id
      listing.destroy
      render json: { message: "Anúncio removido com sucesso" }, status: :ok
    else
      render json: { error: "Você não tem permissão para remover este anúncio" }, status: :forbidden
    end
  end

  private

  def listing_params
    params.require(:book_listing).permit(:title, :author, :price, :image_url, :featured)
  end
end