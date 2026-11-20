module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # O navegador não deixa mandar headers em WebSocket, então o token vem na URL: /cable?token=...
    def find_verified_user
      User.find_by_token_for(:api_session, request.params[:token].to_s) ||
        reject_unauthorized_connection
    end
  end
end
