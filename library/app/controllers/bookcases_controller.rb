class BookcasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookcase, only: %i[ show update destroy ]

  # GET /bookcases  (só as estantes do usuário logado)
  def index
    render json: current_user.bookcases.includes(:books).order(:id)
  end

  # GET /bookcases/1  (estante + livros com o nome do autor)
  def show
    render json: @bookcase, include: :books
  end

  # POST /bookcases  (o dono é sempre o usuário logado; user_id nunca vem do cliente)
  def create
    @bookcase = current_user.bookcases.build(bookcase_params)

    if @bookcase.save
      render json: @bookcase, status: :created, location: @bookcase
    else
      render json: { errors: @bookcase.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /bookcases/1
  def update
    if @bookcase.update(bookcase_params)
      render json: @bookcase
    else
      render json: { errors: @bookcase.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /bookcases/1  (apaga também os livros da estante)
  def destroy
    @bookcase.destroy!
    head :no_content
  end

  private
    # Busca somente entre as estantes do usuário logado: estante de outro usuário => 404.
    def set_bookcase
      @bookcase = current_user.bookcases.includes(books: :author).find(params.expect(:id))
    end

    def bookcase_params
      params.expect(bookcase: [ :name, :limit ])
    end
end
