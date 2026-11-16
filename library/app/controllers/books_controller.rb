class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: %i[ show update destroy ]
  before_action :ensure_own_bookcase, only: %i[ create update ]

  # GET /books  (só os livros das estantes do usuário logado)
  # Filtros opcionais: ?bookcase_id=1 e ?author_id=2  (também via /authors/:author_id/books)
  def index
    @books = current_user.books.includes(:author).order(:id)
    @books = @books.where(author_id: params[:author_id]) if params[:author_id].present?
    @books = @books.where(bookcase_id: params[:bookcase_id]) if params[:bookcase_id].present?

    render json: @books
  end

  # esse método ta sendo chamado la no routes para teste
  def teste
    render json: { message: "Teste de rota" }
  end

  # GET /books/1
  def show
    render json: @book
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created, location: @book
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy!
    head :no_content
  end

  private
    # Busca somente entre os livros das estantes do usuário logado.
    def set_book
      @book = current_user.books.find(params.expect(:id))
    end

    # Ao criar ou mover um livro, a estante de destino precisa ser do usuário logado
    # (senão alguém poderia colocar livros na estante de outra pessoa). Outro dono => 404.
    def ensure_own_bookcase
      book = params[:book]
      return unless book.respond_to?(:key?) # corpo malformado: o params.expect devolve 400

      bookcase_id = book[:bookcase_id]
      return if bookcase_id.blank?

      current_user.bookcases.find(bookcase_id)
    end

    def book_params
      params.expect(book: [ :title, :rating, :bookcase_id, :author_id, :release ])
    end
end
