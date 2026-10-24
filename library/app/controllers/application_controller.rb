class ApplicationController < ActionController::API
  def run_seeds
    Rails.application.load_seed
    render json: { message: "🎉 Base de dados povoada com sucesso via seeds!" }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
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
end