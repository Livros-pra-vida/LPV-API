class CatalogBooksController < ApplicationController
  before_action :authenticate_user!, only: %i[ create destroy ]
  before_action :require_admin!, only: %i[ create destroy ]

  # GET /catalog_books
  # Público: qualquer visitante vê o catálogo e as médias. Se vier um token válido, cada livro
  # também traz a nota que ESSE usuário deu (my_rating). Token ausente ou vencido = visitante.
  # Só um admin recebe também quem cadastrou cada livro (published_by).
  def index
    my_scores = current_user ? current_user.ratings.pluck(:catalog_book_id, :score).to_h : {}
    admin = current_user&.admin? || false

    books = CatalogBook.with_rating_stats.includes(:user).order(:id).map do |book|
      book.as_summary(my_score: my_scores[book.id], include_publisher: admin)
    end

    render json: books
  end

  # POST /catalog_books (somente admin)   corpo: { "catalog_book": { "title": ..., "author_name": ..., ... } }
  # O dono é sempre o admin do token (nunca vem do cliente).
  def create
    book = CatalogBook.new(catalog_book_params.merge(user: current_user))

    if book.save
      registrar_acao_admin("adicionou o livro ao catálogo", book)
      render json: book.as_summary(include_publisher: true), status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: [ "Título já está em uso" ] }, status: :unprocessable_content
  end

  # DELETE /catalog_books/:id (somente admin). Apaga também as avaliações do livro.
  def destroy
    livro = CatalogBook.find(params.expect(:id))
    livro.destroy!
    registrar_acao_admin("removeu o livro do catálogo", livro)
    head :no_content
  end

  private
    def catalog_book_params
      params.expect(catalog_book: [ :title, :author_name, :genre, :price, :image_url, :synopsis ])
    end
end
