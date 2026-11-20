class PrivateMessagesController < ApplicationController
  before_action :authenticate_user!

  rate_limit to: 30, within: 1.minute, only: :create, by: -> { current_user.id },
             with: -> { render json: { errors: [ "Você está enviando mensagens rápido demais." ] }, status: :too_many_requests }

  # POST /conversations/:conversation_id/messages   corpo: { "content": "..." }
  def create
    conversa = Conversation.of_user(current_user).find(params.expect(:conversation_id))
    mensagem = conversa.private_messages.build(user: current_user, content: params[:content].to_s.strip)

    if mensagem.save
      render json: mensagem.payload, status: :created
    else
      render json: { errors: mensagem.errors.full_messages }, status: :unprocessable_content
    end
  end
end
