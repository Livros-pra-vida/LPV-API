class BookListingsController < ApplicationController
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :require_admin!, only: %i[ destroy ]

  # Evita que alguém encha o banco de anúncios (cada um pode ter imagem de até 400 KB).
  rate_limit to: 10, within: 10.minutes, only: :create, by: -> { current_user.id },
             with: -> { render json: { errors: [ "Muitos anúncios seguidos. Aguarde alguns minutos." ] }, status: :too_many_requests }

  # GET /book_listings (público): anúncios do Comprar & Trocar, do mais novo para o mais antigo.
  def index
    render json: BookListing.includes(:user).order(created_at: :desc, id: :desc).map(&:as_summary)
  end

  # POST /book_listings   corpo: { "book_listing": { "title": ..., "modality": "Venda", "price": 35, ... } }
  # O anunciante é sempre o usuário do token (nunca vem do cliente).
  def create
    listing = BookListing.new(listing_params.merge(user: current_user))

    if listing.save
      render json: listing.as_summary, status: :created
    else
      render json: { errors: listing.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH /book_listings/:id   só o dono do anúncio (ou um admin) muda o status.
  # Status "Indisponivel" = venda/troca concluída: a reputação do anunciante sobe junto.
  def update
    listing = BookListing.find(params.expect(:id))
    return head :forbidden unless listing.user_id == current_user.id || current_user.admin?

    novo_status = params.expect(book_listing: [ :status ])[:status]

    if novo_status == "Indisponivel" && listing.status != "Indisponivel"
      listing.conclude!
    elsif !listing.update(status: novo_status)
      return render json: { errors: listing.errors.full_messages }, status: :unprocessable_content
    end

    render json: listing.as_summary
  end

  # DELETE /book_listings/:id (somente admin)
  def destroy
    BookListing.find(params.expect(:id)).destroy!
    head :no_content
  end

  private
    def listing_params
      params.expect(book_listing: [ :title, :author_name, :modality, :price, :region, :image_url ])
    end
end
