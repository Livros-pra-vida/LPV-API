class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_global"
  end

  def speak(data)
    content = data["content"].to_s.strip
    return if content.blank?

    # anti-spam: no máximo 1 mensagem por segundo por usuário
    return if Message.where(user: current_user).where("created_at > ?", 1.second.ago).exists?

    Message.create(user: current_user, content: content)
  end
end
