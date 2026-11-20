class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ me index show update destroy ]
  before_action :require_admin!, only: %i[ index ]
  before_action :authorize_self!, only: %i[ show update destroy ]
  before_action :set_user, only: %i[ show update destroy ]

  # Proteção contra força bruta: no máximo 10 tentativas de login e 5 cadastros
  # por IP a cada 3 minutos. Depois disso a API responde 429 (muitas tentativas).
  rate_limit to: 10, within: 3.minutes, only: :login,
             with: -> { render json: { error: "Muitas tentativas. Aguarde alguns minutos e tente de novo." }, status: :too_many_requests }
  rate_limit to: 5, within: 3.minutes, only: :create,
             with: -> { render json: { errors: [ "Muitos cadastros seguidos. Aguarde alguns minutos." ] }, status: :too_many_requests }

  # POST /users/login   corpo: { "email": "...", "password": "senha digitada" }
  def login
    email = params[:email].to_s.strip.downcase
    @user = email.present? ? User.where("LOWER(email) = ?", email).first : nil

    if @user&.authenticate(params[:password].to_s)
      render json: {
        token: @user.generate_token_for(:api_session),
        user: @user.as_owner_json,
        message: "Login realizado com sucesso!"
      }, status: :ok
    else
      render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
    end
  end

  # GET /users/me
  def me
    render json: current_user.as_owner_json, status: :ok
  end

  # GET /users (somente admin) — sem CPF, telefone e endereço de ninguém.
  def index
    render json: User.order(:id).map(&:as_public_json)
  end

  # GET /users/:id   o dono vê tudo; o admin vendo outra pessoa vê só o básico.
  def show
    render json: json_para(@user)
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: { token: @user.generate_token_for(:api_session), user: @user.as_owner_json }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /users/:id
  # Trocar e-mail ou senha exige a senha atual (se alguém pegar o token, não toma a conta).
  def update
    if @user.id != current_user.id
      # Admin mexendo em outra pessoa: só pode ligar/desligar o admin de um usuário comum.
      return render json: { error: "Não é possível editar outro administrador" }, status: :forbidden if @user.admin?

      return render json: @user.as_public_json if @user.update(params.require(:user).permit(:admin))
      return render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end

    dados = user_params
    mudando_acesso = dados[:password].present? ||
                     (dados.key?(:email) && dados[:email].to_s.strip.casecmp?(@user.email.to_s) == false)

    if mudando_acesso && !@user.authenticate(params.dig(:user, :current_password).to_s)
      return render json: { errors: [ "Para trocar o e-mail ou a senha, informe a sua senha atual corretamente" ] },
                    status: :unprocessable_content
    end

    if @user.update(dados)
      resposta = @user.as_owner_json
      # Se a senha mudou, o token antigo deixou de valer: devolve um novo para continuar logado.
      resposta = resposta.merge("token" => @user.generate_token_for(:api_session)) if dados[:password].present?
      render json: resposta, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /users/:id
  # O próprio usuário apaga a conta; um admin apaga a de qualquer usuário comum
  # (mensagens, estantes, avaliações e anúncios dele somem junto), mas não a de outro admin.
  def destroy
    if @user.admin? && @user.id != current_user.id
      return render json: { error: "Não é possível excluir outro administrador" }, status: :forbidden
    end

    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def json_para(user)
    user.id == current_user.id ? user.as_owner_json : user.as_public_json
  end

  # Só o próprio usuário (ou um admin) pode ver, editar ou apagar a conta.
  def authorize_self!
    head :forbidden unless params[:id].to_s == current_user.id.to_s || current_user.admin?
  end

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation, :telefone, :nascimento, :cpf,
      :cep, :rua, :numero, :bairro, :cidade, :pagamento_favorito, :avatar_url
    )
  end
end
