class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    # Cria a mensagem associada ao usuário autenticado atual (current_user)
    message = current_user.messages.build(content: data["content"])
    
    if message.save
      # Transmite a mensagem formatada para todos os assinantes do canal
      ActionCable.server.broadcast("chat_channel", {
        id: message.id,
        username: current_user.username,
        content: message.content,
        created_at: message.created_at
      })
    end
  end
end