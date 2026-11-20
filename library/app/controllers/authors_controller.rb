class AuthorsController < ApplicationController
  # Autores são um cadastro compartilhado: qualquer usuário logado lê e cria,
  # mas só admin edita ou apaga (para ninguém bagunçar o autor de outras pessoas).
  before_action :authenticate_user!
  before_action :require_admin!, only: %i[ update destroy ]
  before_action :set_author, only: %i[ show update destroy ]

  # GET /authors
  def index
    @authors = Author.order(:name)

    render json: @authors
  end

  # GET /authors/1
  def show
    render json: @author
  end

  # POST /authors
  def create
    @author = Author.new(author_params)

    if @author.save
      render json: @author, status: :created, location: @author
    else
      render json: { errors: @author.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /authors/1
  def update
    if @author.update(author_params)
      render json: @author
    else
      render json: { errors: @author.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /authors/1
  def destroy
    @author.destroy!
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params.expect(:id))
    end

<<<<<<< HEAD
=======
    def require_admin!
      head :forbidden unless current_user.admin?
    end

>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426
    # Only allow a list of trusted parameters through.
    def author_params
      params.expect(author: [ :name, :description ])
    end
end
