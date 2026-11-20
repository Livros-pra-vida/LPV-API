class MessagesController < ApplicationController
  before_action :authenticate_user!

  # Anti-spam pela API (o canal do chat já tinha): no máximo 20 mensagens por minuto por usuário.
  rate_limit to: 20, within: 1.minute, only: :create, by: -> { current_user.id },
             with: -> { render json: { errors: [ "Você está enviando mensagens rápido demais." ] }, status: :too_many_requests }

  # GET /messages: últimas 50 mensagens do chat global
  def index
    messages = Message.includes(:user).order(created_at: :asc).last(50)
    render json: messages.map { |m| {
      id: m.id,
      user_id: m.user_id,
      username: m.user&.username || "Usuário",
      content: m.content,
      created_at: m.created_at
    }}
  end

  # POST /messages
  def create
    content_text = params[:content] || params.dig(:message, :content)

    if content_text.blank?
      return render json: { errors: ["A mensagem não pode ficar em branco"] }, status: :unprocessable_content
    end

    message = current_user.messages.build(content: content_text)

    if message.save
      render json: {
        id: message.id,
        user_id: current_user.id,
        username: current_user.username,
        content: message.content,
        created_at: message.created_at
      }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /messages/:id (somente admin): apaga a mensagem de qualquer pessoa.
  # O model avisa os chats abertos para a mensagem sumir da tela na hora.
  def destroy
    return render json: { error: "Apenas administradores" }, status: :forbidden unless current_user.admin?

    Message.find(params[:id]).destroy!
    head :no_content
  end
end
