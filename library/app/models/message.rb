# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 500 }

  after_create_commit :broadcast_message
  after_destroy_commit :broadcast_removal

  def payload
    { id: id, user_id: user_id, username: user.username, content: content, created_at: created_at }
  end

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_global", payload)
  end

  # Avisa os chats abertos que a mensagem foi apagada (o front remove da tela).
  def broadcast_removal
    ActionCable.server.broadcast("chat_global", { id: id, deleted: true })
  end
end