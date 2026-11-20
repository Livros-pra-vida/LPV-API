# Tempo real do chat privado: cada conversa tem o seu canal, e só os dois participantes entram.
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversa = Conversation.find_by(id: params[:conversation_id])
    if conversa&.participant?(current_user)
      stream_for conversa
    else
      reject
    end
  end
end
