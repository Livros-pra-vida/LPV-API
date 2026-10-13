class ApplicationController < ActionController::API
  private

  # Usuário dono do token enviado no header "Authorization: Bearer <token>"
  def current_user
    @current_user ||= User.find_by_token_for(:api_session, bearer_token)
  end

  def bearer_token
    request.headers["Authorization"].to_s.delete_prefix("Bearer ").strip
  end

  def authenticate_user!
    render json: { error: "Não autorizado" }, status: :unauthorized unless current_user
  end
end
