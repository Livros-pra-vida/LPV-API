class BookListingsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    @listings = BookListing.includes(:user).order(created_at: :desc)
    render json: @listings.map { |listing| {
      id: listing.id,
      title: listing.title,
      author: listing.author,
      price: listing.price,
      image_url: listing.image_url,
      featured: listing.featured,
      user_id: listing.user_id,
      username: listing.user&.username || "Anônimo",
      created_at: listing.created_at
    }}
  end

  def create
    listing = current_user.book_listings.build(listing_params)
    if listing.save
      render json: {
        id: listing.id,
        title: listing.title,
        author: listing.author,
        price: listing.price,
        image_url: listing.image_url,
        featured: listing.featured,
        user_id: listing.user_id,
        username: current_user.username
      }, status: :created
    else
      render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    listing = BookListing.find_by(id: params[:id])
    return render json: { error: "Anúncio não encontrado" }, status: :not_found unless listing

    if params[:book_listing] && params[:book_listing][:featured] != nil
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