# Mensagem do chat privado. O texto é gravado CRIPTOGRAFADO no banco (AES-256-GCM):
# no PostgreSQL só aparece um JSON embaralhado; só a API, com a chave, consegue ler.
class PrivateMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  encrypts :content

  validates :content, presence: true, length: { maximum: 1000 }
  validate :autor_participa_da_conversa

  after_create_commit :avisar_participantes

  def payload
    { id: id, conversation_id: conversation_id, user_id: user_id, username: user.username,
      content: content, created_at: created_at, read_at: read_at }
  end

  private

  def autor_participa_da_conversa
    errors.add(:base, "Você não participa desta conversa") unless conversation&.participant?(user)
  end

  # Atualiza a conversa e manda a mensagem em tempo real para quem estiver com ela aberta.
  def avisar_participantes
    conversation.update_column(:last_message_at, created_at)
    ConversationChannel.broadcast_to(conversation, payload)
  end
end
