class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # POST /users/login
  def login
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      token = @user.signed_id(purpose: :api_session, expires_in: 12.hours)
      render json: { 
        token: token, 
        user: @user.serializable_hash(except: [:password_digest]),
        message: "Login realizado com sucesso!" 
      }, status: :ok
    else
      render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
    end
  end

  # GET /users/me
  def me
    token = request.headers['Authorization']&.split(' ')&.last
    @user = User.find_signed(token, purpose: :api_session)
    if @user
      render json: @user, status: :ok
    else
      render json: { error: "Não autorizado" }, status: :unauthorized
    end
  end

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      token = @user.signed_id(purpose: :api_session, expires_in: 12.hours)
      render json: { token: token, user: @user }, status: :created
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

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :telefone, :nascimento, 
      :cpf, :cep, :rua, :numero, :bairro, :cidade, 
      :pagamento_favorito, :avatar_url, :admin
    )
  end
end