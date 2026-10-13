class MessagesController < ApplicationController
  before_action :authenticate_user!

  # GET /messages  -> últimas 50 mensagens do chat global
  def index
    messages = Message.includes(:user).order(id: :desc).limit(50).reverse
    render json: messages.map(&:payload)
  end
end
