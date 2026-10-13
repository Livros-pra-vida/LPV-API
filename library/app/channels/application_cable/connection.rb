# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # AJUSTAR: decodificar o token como o resto da API faz
      user = User.find_by(id: decoded_user_id(request.params[:token]))
      user || reject_unauthorized_connection
    end
  end
end