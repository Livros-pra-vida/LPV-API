# Chat privado de negociação (comprador <-> anunciante). Tudo fica salvo no banco, com o texto criptografado.
class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: %i[ show ]

  # GET /conversations   minhas conversas, da mais recente para a mais antiga
  def index
    conversas = Conversation.of_user(current_user)
                            .includes(:buyer, :seller, :book_listing, :private_messages)
                            .order(Arel.sql("COALESCE(conversations.last_message_at, conversations.created_at) DESC"))
    render json: conversas.map { |c| c.summary_for(current_user) }
  end

  # GET /conversations/:id   dados da conversa + mensagens (e marca as recebidas como lidas)
  def show
    @conversation.private_messages.where(read_at: nil).where.not(user_id: current_user.id).update_all(read_at: Time.current)
    render json: @conversation.summary_for(current_user).merge(
      messages: @conversation.private_messages.includes(:user).last(200).map(&:payload)
    )
  end

  # POST /conversations   corpo: { "book_listing_id": 3, "message": "Olá! Ainda está disponível?" }
  # Abre (ou reaproveita) a conversa com o anunciante. A mensagem inicial é opcional.
  def create
    anuncio = BookListing.find(params.expect(:book_listing_id))

    if anuncio.user_id.nil?
      return render json: { errors: [ "Este é um anúncio de exemplo, sem anunciante cadastrado para conversar" ] },
                    status: :unprocessable_content
    end

    conversa = Conversation.find_or_initialize_by(book_listing_id: anuncio.id, buyer_id: current_user.id) do |c|
      c.seller_id = anuncio.user_id
      c.listing_title = anuncio.title
    end

    Conversation.transaction do
      conversa.save!
      texto = params[:message].to_s.strip
      conversa.private_messages.create!(user: current_user, content: texto) if texto.present? && conversa.private_messages.none?
    end

    render json: conversa.summary_for(current_user), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  private

  # Conversa de outra pessoa = 404 (não revela que existe).
  def set_conversation
    @conversation = Conversation.of_user(current_user).find(params.expect(:id))
  end
end
