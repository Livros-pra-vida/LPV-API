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
    render json: { error: "Não autorizado" }, status: :unauthorized unless current_user
  end

  # Ações do administrador. A checagem é sempre aqui no servidor: o front só esconde os botões.
  def require_admin!
    render json: { error: "Apenas administradores" }, status: :forbidden unless current_user&.admin?
  end
end
