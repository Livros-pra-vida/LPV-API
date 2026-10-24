class MessagesController < ApplicationController
  # Removido temporariamente para liberar o chat global sem barreiras de token
  # before_action :authenticate_user!

  def index
    messages = Message.includes(:user).order(created_at: :asc).last(50)
    render json: messages.map { |m| {
      id: m.id,
      username: m.user&.username || "Usuário",
      content: m.content,
      created_at: m.created_at
    }}
  end

  def create
    content_text = params[:content] || (params[:message] && params[:message][:content])

    if content_text.blank?
      return render json: { errors: ["A mensagem não pode ficar em branco"] }, status: :unprocessable_entity
    end

    # Tenta pegar o usuário logado via helper atual ou busca pelo ID enviado, senão pega o primeiro do banco
    user_obj = defined?(current_user) && current_user.present? ? current_user : (User.find_by(id: params[:user_id]) || User.first)

    if user_obj
      message = user_obj.messages.build(content: content_text)
    else
      message = Message.new(content: content_text, user: User.first)
    end

    if message.save
      render json: { 
        id: message.id, 
        username: message.user&.username || "Leitor", 
        content: message.content, 
        created_at: message.created_at 
      }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end
end