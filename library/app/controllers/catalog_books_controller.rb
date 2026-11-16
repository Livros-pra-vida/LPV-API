class CatalogBooksController < ApplicationController
  # GET /catalog_books
  # Público: qualquer visitante vê as médias. Se vier um token válido, cada livro
  # também traz a nota que ESSE usuário deu (my_rating). Token ausente ou vencido = visitante.
  def index
    my_scores = current_user ? current_user.ratings.pluck(:catalog_book_id, :score).to_h : {}

    books = CatalogBook.with_rating_stats.order(:id).map do |book|
      book.as_summary(my_score: my_scores[book.id])
    end

    render json: books
  end
end
