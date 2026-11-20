class WishAlertsController < ApplicationController
  before_action :authenticate_user!

  # GET /wish_alerts   alertas do usuário, cada um com os anúncios que já combinam com ele
  def index
    render json: current_user.wish_alerts.order(created_at: :desc).map(&:as_summary)
  end

  # POST /wish_alerts   corpo: { "term": "Duna" }
  def create
    alerta = current_user.wish_alerts.build(term: params[:term].to_s.strip)
    if alerta.save
      render json: alerta.as_summary, status: :created
    else
      render json: { errors: alerta.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /wish_alerts/:id
  def destroy
    current_user.wish_alerts.find(params.expect(:id)).destroy!
    head :no_content
  end
end
