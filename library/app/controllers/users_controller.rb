class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ me index show update destroy ]
  before_action :require_admin!, only: %i[ index ]
  before_action :authorize_self!, only: %i[ show update destroy ]
  before_action :set_user, only: %i[ show update destroy ]

  # POST /users/login
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      render json: {
        token: @user.generate_token_for(:api_session),
        user: @user,
        message: "Login realizado com sucesso!"
      }, status: :ok
    else
      render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
    end
  end

  # GET /users/me
  def me
    render json: current_user, status: :ok
  end

  # GET /users (somente admin)
  def index
    render json: User.all
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: { token: @user.generate_token_for(:api_session), user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Só o próprio usuário (ou um admin) pode ver, editar ou apagar a conta.
  def authorize_self!
    head :forbidden unless params[:id].to_s == current_user.id.to_s || current_user.admin?
  end

  def require_admin!
    head :forbidden unless current_user.admin?
  end

  def user_params
    permitidos = [
      :username, :email, :password, :telefone, :nascimento,
      :cpf, :cep, :rua, :numero, :bairro, :cidade,
      :pagamento_favorito, :avatar_url
    ]
    # Só um admin logado pode alterar o campo admin. No cadastro ninguém vira admin.
    permitidos << :admin if current_user&.admin?
    params.require(:user).permit(*permitidos)
  end
end
