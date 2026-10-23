module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Tenta pegar o token da query string da URL do WebSocket
      token = request.params[:token].to_s.strip
      return reject_unauthorized_connection if token.blank?

      # Procura o usuário pelo token (ajuste conforme a sua gema de autenticação, ex: Warden, Devise, ou JWT manual)
      # Se estiver a usar o mecanismo nativo do Rails has_secure_token:
      User.find_by_token_for(:api_session, token) || reject_unauthorized_connection
    rescue StandardError
      reject_unauthorized_connection
    end
  end
end