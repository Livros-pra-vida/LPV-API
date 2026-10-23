class BooksController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  # GET /books - Busca do banco PostgreSQL
  def index
    @books = Book.order(created_at: :desc)
    render json: @books
  end

  # POST /books - Salva direto no PostgreSQL
  def create
    book = Book.new(book_params)
    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /books/:id - Atualiza o Destaque direto na tabela do PostgreSQL
  def update
    book = Book.find_by(id: params[:id])

    if book
      book.update_column(:featured, params[:book][:featured])
      render json: book, status: :ok
    else
      render json: { error: "Livro não encontrado" }, status: :not_found
    end
  end

  # DELETE /books/:id - Remove direto do PostgreSQL
  def destroy
    book = Book.find_by(id: params[:id])
    if book
      book.destroy
      render json: { message: "Livro removido do banco com sucesso" }, status: :ok
    else
      render json: { message: "Livro removido" }, status: :ok
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :genre, :price, :rating, :image_url, :description, :featured)
  end
end