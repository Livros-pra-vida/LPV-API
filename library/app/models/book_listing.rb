class BookListing < ApplicationRecord
  MODALITIES = %w[ Venda Troca Doação ].freeze
  STATUSES = [ "Disponivel", "Em Negociacao", "Indisponivel" ].freeze

  belongs_to :user, optional: true # anúncios de exemplo não têm dono

  validates :title, presence: true, length: { maximum: 200 }
  validates :author_name, presence: true, length: { maximum: 200 }
  validates :modality, inclusion: { in: MODALITIES }
  validates :status, inclusion: { in: STATUSES }
  validates :region, length: { maximum: 80 }
  validates :image_url, length: { maximum: 400_000 }
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 100_000 }, if: -> { modality == "Venda" }
  validates :price, absence: true, unless: -> { modality == "Venda" }

  # Nome mostrado como anunciante: o do usuário dono ou, nos anúncios de exemplo, o texto fixo.
  def seller
    user&.username || seller_name
  end

  # Marca a venda/troca como concluída e soma 1 na reputação do anunciante ("5.0 (3 trocas)").
  def conclude!
    anteriores = reputation.to_s[/\((\d+)/, 1].to_i
    update!(status: "Indisponivel",
            reputation: "5.0 (#{anteriores + 1} #{modality == 'Venda' ? 'vendas' : 'trocas'})")
  end

  def as_summary
    {
      id: id,
      title: title,
      author_name: author_name,
      modality: modality,
      price: price&.to_f,
      region: region,
      status: status,
      image_url: image_url,
      reputation: reputation,
      seller: seller,
      seller_id: user_id
    }
  end
end
