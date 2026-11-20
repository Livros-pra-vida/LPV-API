# Painel do Administrador. Tudo aqui exige login de admin, e cada ação fica registrada.
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: %i[ suspend reactivate set_admin ]

  # GET /admin/dashboard   números gerais do site
  def dashboard
    hoje = Time.current.beginning_of_day
    render json: {
      usuarios: User.count,
      novos_usuarios_7_dias: User.where("created_at >= ?", 7.days.ago).count,
      administradores: User.where(admin: true).count,
      suspensos: User.where.not(suspended_at: nil).count,
      anuncios_ativos: BookListing.where.not(status: "Indisponivel").count,
      livros_catalogo: CatalogBook.count,
      pedidos: Order.count,
      pedidos_em_aberto: Order.where(status: [ "Em separação", "Enviado" ]).count,
      faturamento: Order.where.not(status: "Cancelado").sum(:total).to_f,
      mensagens_chat_hoje: Message.where("created_at >= ?", hoje).count,
      negociacoes: Conversation.count,
      novidades: NewsPost.count
    }
  end

  # GET /admin/users?q=texto   lista de usuários (sem CPF, telefone nem endereço)
  def users
    lista = User.order(created_at: :desc)
    if params[:q].present?
      termo = "%#{User.sanitize_sql_like(params[:q].to_s.strip)}%"
      lista = lista.where("username ILIKE ? OR email ILIKE ?", termo, termo)
    end
    render json: lista.limit(200).map { |u|
      u.as_public_json.merge(
        "anuncios" => u.book_listings.count,
        "pedidos" => u.orders.count,
        "mensagens" => u.messages.count
      )
    }
  end

  # POST /admin/users/:id/suspend   corpo: { "reason": "Spam no chat" }
  def suspend
    return render_erro("Você não pode suspender a própria conta") if @user.id == current_user.id
    return render_erro("Não é possível suspender outro administrador") if @user.admin?

    motivo = params[:reason].to_s.strip.truncate(250)
    return render_erro("Informe o motivo da suspensão") if motivo.blank?

    @user.update_columns(suspended_at: Time.current, suspended_reason: motivo)
    registrar_acao_admin("suspendeu a conta", @user, motivo)
    render json: @user.as_public_json
  end

  # POST /admin/users/:id/reactivate
  def reactivate
    @user.update_columns(suspended_at: nil, suspended_reason: nil)
    registrar_acao_admin("reativou a conta", @user)
    render json: @user.as_public_json
  end

  # PATCH /admin/users/:id/admin   corpo: { "admin": true }
  # Promover qualquer usuário; tirar o admin só da própria conta (um admin não rebaixa outro).
  def set_admin
    novo = ActiveModel::Type::Boolean.new.cast(params[:admin])
    if !novo && @user.id != current_user.id
      return render_erro("Não é possível remover o administrador de outra pessoa")
    end
    return render_erro("Reative a conta antes de torná-la administradora") if novo && @user.suspended?
    if !novo && User.where(admin: true).count <= 1
      return render_erro("O site precisa ter pelo menos um administrador")
    end

    @user.update_column(:admin, novo)
    registrar_acao_admin(novo ? "tornou administrador" : "deixou de ser administrador", @user)
    render json: @user.as_public_json
  end

  # GET /admin/orders?status=Enviado   todos os pedidos da loja
  def orders
    lista = Order.includes(:order_items, :user).order(created_at: :desc)
    lista = lista.where(status: params[:status]) if params[:status].present?
    render json: lista.limit(200).map { |o| o.as_summary.merge(customer: { id: o.user_id, name: o.user&.username }) }
  end

  # PATCH /admin/orders/:id   corpo: { "status": "Enviado" }
  def update_order
    pedido = Order.find(params.expect(:id))
    anterior = pedido.status
    if pedido.update(status: params[:status].to_s)
      registrar_acao_admin("mudou o status do pedido", pedido, "#{anterior} → #{pedido.status}")
      render json: pedido.as_summary.merge(customer: { id: pedido.user_id, name: pedido.user&.username })
    else
      render json: { errors: pedido.errors.full_messages }, status: :unprocessable_content
    end
  end

  # GET /admin/actions   registro das últimas ações de moderação
  def actions
    render json: AdminAction.order(created_at: :desc).limit(200).map(&:as_summary)
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end

  def render_erro(texto)
    render json: { error: texto, errors: [ texto ] }, status: :unprocessable_content
  end
end
