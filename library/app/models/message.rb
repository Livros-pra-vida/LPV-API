# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 500 }

  after_create_commit :broadcast_message

  def payload
    { id: id, username: user.username, content: content, created_at: created_at }
  end

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_global", payload)
  end
end