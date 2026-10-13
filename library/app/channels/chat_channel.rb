# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_global"
  end

  def speak(data)
    Message.create(user: current_user, content: data["content"].to_s.strip)
  end
end