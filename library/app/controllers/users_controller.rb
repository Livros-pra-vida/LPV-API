class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index destroy me ]
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    # Apenas o Admin pode listar todos os usuários cadastrados
    return render json: { error: "Acesso negado" }, status: :forbidden unless current_user&.admin?

    @users = User.all
    render json: @users
  end

  # GET /users/me
  def me
    render json: current_user
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users/login
  def login
    @user = User.find_by(email: params[:email]) || User.find_by(username: params[:email])

    if @user&.authenticate(params[:password])
      render json: {
        message: "Login realizado com sucesso",
        token: @user.generate_token_for(:api_session),
        user: {
          id: @user.id,
          username: @user.username,
          email: @user.email,
          admin: @user.admin
        }
      }, status: :ok
    else
      render json: { error: "E-mail ou senha incorretos" }, status: :unauthorized
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      secret_key = Rails.application.secret_key_base || "chave_secreta_fallback"
      payload = {
        user_id: @user.id,
        admin: @user.admin,
        exp: 24.hours.from_now.to_i
      }
      token_jwt = JWT.encode(payload, secret_key, 'HS256')

      render json: {
        message: "Usuário criado com sucesso",
        token: token_jwt,
        user: {
          id: @user.id,
          username: @user.username,
          email: @user.email,
          admin: @user.admin
        }
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    # O próprio usuário pode apagar sua conta, OU o Admin pode apagar qualquer conta
    return render json: { error: "Acesso negado" }, status: :forbidden unless current_user&.id == @user.id || current_user&.admin?

    @user.destroy!
    render json: { message: "Usuário removido com sucesso" }, status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation,
      :telefone, :cpf, :nascimento,
      :cep, :rua, :numero, :bairro, :cidade, :pagamento_favorito
    )
  end
end