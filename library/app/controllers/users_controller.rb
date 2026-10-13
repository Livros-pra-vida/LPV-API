class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end



  # GET /users/1
  def show
    render json: @user
  end

  # GET /users/login
  def login
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      render json: {
        message: "Login successful",
        user: @user
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end


  # POST /users
  def create
     @user = User.new(user_params)

  if @user.save
    render json: {
      message: "Usuário criado com sucesso",
      user: @user.as_json(except: [:password_digest])
    }, status: :created
  else
    render json: {
      errors: @user.errors.full_messages
    }, status: :unprocessable_entity
  end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [
    :username,
    :email,
    :password,
    :password_confirmation,
    :telefone,
    :cpf,
    :nascimento,
    :admin
      ])
    end
end
