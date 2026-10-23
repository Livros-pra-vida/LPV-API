class BooksController < ApplicationController
  # GET /books
  def index
    @books = Book.includes(:author, :estante).order(created_at: :desc)
    
    # Mapeia cada livro para injetar o nome do autor como string diretamente no JSON
    books_json = @books.map do |book|
      book.as_json.merge(author: book.author&.name || "Desconhecido")
    end

    render json: books_json
  end

  # POST /books
  def create
    nome_autor = params.dig(:book, :author)
    
    # Busca ou cria o autor na tabela 'authors'
    autor = Author.find_or_create_by!(name: nome_autor) if nome_autor.present?
    
    # Garante uma estante padrão para satisfazer a relação do banco
    estante = Bookcase.first || Bookcase.create!(name: "Estante Geral da Loja", limit: 500)

    book = Book.new(
      title: params.dig(:book, :title),
      genre: params.dig(:book, :genre),
      price: params.dig(:book, :price),
      image_url: params.dig(:book, :image_url),
      description: params.dig(:book, :description),
      rating: params.dig(:book, :rating) || 5,
      featured: false,
      author_id: autor&.id,
      bookcase_id: estante.id
    )

    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /books/:id
  def update
    book = Book.find_by(id: params[:id])
    if book
      book.update_column(:featured, params[:book][:featured])
      render json: book, status: :ok
    else
      render json: { error: "Livro não encontrado no PostgreSQL" }, status: :not_found
    end
  end

  # DELETE /books/:id
  def destroy
    book = Book.find_by(id: params[:id])
    if book
      book.destroy
      render json: { message: "Livro removido com sucesso" }, status: :ok
    else
      render json: { error: "Livro não encontrado no PostgreSQL" }, status: :not_found
    end
  end
end