class OrdersController < ApplicationController
  before_action :authenticate_user!

  # GET /orders   meus pedidos, do mais novo para o mais antigo
  def index
    render json: current_user.orders.includes(:order_items).order(created_at: :desc).map(&:as_summary)
  end

  # POST /orders   corpo: { "payment_method": "Pix" }
  # Fecha o pedido com o carrinho salvo no banco e o endereço do perfil.
  def create
    unless current_user.endereco_completo?
      return render json: { errors: [ "Preencha seu endereço de entrega no perfil antes de finalizar o pedido" ] },
                    status: :unprocessable_content
    end

    pagamento = params[:payment_method].presence || current_user.pagamento_favorito.presence || "Pix"
    pedido = Order.checkout!(current_user, pagamento)
    return render json: { errors: [ "Seu carrinho está vazio" ] }, status: :unprocessable_content if pedido.nil?

    render json: pedido.as_summary, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end
end
