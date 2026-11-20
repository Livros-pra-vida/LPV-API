# Registro (auditoria) das ações dos administradores. Ninguém edita nem apaga pela API.
class AdminAction < ApplicationRecord
  belongs_to :admin, class_name: "User", optional: true

  validates :admin_name, :action, presence: true

  # AdminAction.registrar!(admin, "excluiu o anúncio", anuncio, "motivo...")
  def self.registrar!(admin, acao, alvo = nil, detalhes = nil)
    create!(
      admin: admin,
      admin_name: admin&.username || "Sistema",
      action: acao,
      target_type: alvo&.class&.name,
      target_id: alvo&.id,
      target_label: rotulo(alvo),
      details: detalhes.presence&.to_s&.truncate(1000)
    )
  end

  def self.rotulo(alvo)
    return nil if alvo.nil?

    %i[ username title listing_title name ].each do |campo|
      return alvo.public_send(campo).to_s.truncate(120) if alvo.respond_to?(campo) && alvo.public_send(campo).present?
    end
    return "Pedido ##{alvo.id}" if alvo.is_a?(Order)
    return "Mensagem: #{alvo.content.to_s.truncate(60)}" if alvo.respond_to?(:content)

    "#{alvo.class.name} ##{alvo.id}"
  end

  def as_summary
    as_json(only: %i[ id admin_id admin_name action target_type target_id target_label details created_at ])
  end
end
