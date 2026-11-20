class ApplicationController < ActionController::API
  # Senhas podem chegar criptografadas pelo navegador (veja concerns/senha_criptografada.rb).
  include SenhaCriptografada

  # Registro inexistente OU de outro usuário (ex.: estante alheia) volta como 404,
  # sem revelar se o registro existe.
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Não encontrado" }, status: :not_found
  end

  private

  def current_user
    @current_user ||= User.find_by_token_for(:api_session, bearer_token)
  end

  def bearer_token
    request.headers["Authorization"].to_s.delete_prefix("Bearer ").strip
  end

  def authenticate_user!
    return render json: { error: "Não autorizado" }, status: :unauthorized unless current_user

    if current_user.suspended?
      render json: { error: mensagem_suspensao(current_user), suspended: true }, status: :forbidden
    end
  end

  def mensagem_suspensao(user)
    motivo = user.suspended_reason.presence
    "Sua conta está suspensa por um administrador#{motivo ? ". Motivo: #{motivo}" : ''}. Fale com o suporte."
  end

  # Guarda no registro de moderação o que o admin fez (aparece no Painel do Administrador).
  def registrar_acao_admin(acao, alvo = nil, detalhes = nil)
    AdminAction.registrar!(current_user, acao, alvo, detalhes)
  end

  # Ações do administrador. A checagem é sempre aqui no servidor: o front só esconde os botões.
  def require_admin!
    render json: { error: "Apenas administradores" }, status: :forbidden unless current_user&.admin?
  end
end
