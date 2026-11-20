# Notícia ou lançamento da página Novidades. Só administradores publicam.
class NewsPost < ApplicationRecord
  KINDS = %w[ noticia lancamento ].freeze
  CATEGORIES = %w[ livros mangas adaptacoes ].freeze

  belongs_to :user, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :category, inclusion: { in: CATEGORIES, message: "deve ser livros, mangas ou adaptacoes" }
  validates :title, presence: true, length: { maximum: 200 }
  validates :summary, length: { maximum: 1000 }
  validates :source_name, length: { maximum: 120 }
  validates :source_url, length: { maximum: 500 },
                         format: { with: %r{\Ahttps?://}i, message: "precisa começar com http:// ou https://" }, allow_blank: true
  validates :image_url, length: { maximum: 400_000 },
                        format: { with: %r{\A(https://|data:image/(png|jpe?g|webp|gif);base64,)}i, message: "precisa ser um link https ou uma imagem" },
                        allow_blank: true
  validates :release_date, presence: { message: "é obrigatória para lançamentos" }, if: -> { kind == "lancamento" }

  scope :noticias, -> { where(kind: "noticia").order(featured: :desc, created_at: :desc) }
  scope :lancamentos, -> { where(kind: "lancamento").order(:release_date) }

  def as_summary(include_author: false)
    resumo = as_json(only: %i[ id kind category title summary source_name source_url image_url featured release_date created_at updated_at ])
    resumo["published_by"] = user && { id: user.id, name: user.username } if include_author
    resumo
  end
end
