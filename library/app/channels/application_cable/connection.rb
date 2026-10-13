module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # TEMPORÁRIO: troque pela decodificação do seu token quando eu souber como o login funciona
      user = User.find_by(id: decoded_user_id(request.params[:token]))
      user || reject_unauthorized_connection
    end

    def decoded_user_id(token)
      nil
    end
  end
end