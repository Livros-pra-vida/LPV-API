class MessagesController < ApplicationController
  before_action :authenticate_user! # Ajuste conforme sua autenticação

  def index
    messages = Message.order(created_at: :asc).last(50)
    render json: messages.map { |m| {
      id: m.id,
      username: m.user.username,
      content: m.content,
      created_at: m.created_at
    }}
  end

  def create
    message = current_user.messages.build(message_params)
    if message.save
      render json: { id: message.id, username: current_user.username, content: message.content, created_at: message.created_at }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end