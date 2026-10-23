class NewsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    @news = News.order(created_at: :desc)
    render json: @news
  end

  def create
    return render json: { error: "Apenas administradores podem postar notícias" }, status: :forbidden unless current_user.admin?

    news = News.new(news_params)
    if news.save
      render json: news, status: :created
    else
      render json: { errors: news.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Permite ao Admin marcar ou desmarcar a notícia em destaque na Home
  def update
    return render json: { error: "Apenas administradores podem gerenciar destaques" }, status: :forbidden unless current_user.admin?

    news = News.find_by(id: params[:id])
    if news && news.update(featured: params[:news][:featured])
      render json: news, status: :ok
    else
      render json: { error: "Não foi possível atualizar o destaque" }, status: :unprocessable_entity
    end
  end

  def destroy
    return render json: { error: "Apenas administradores podem apagar notícias" }, status: :forbidden unless current_user.admin?

    news = News.find_by(id: params[:id])
    if news
      news.destroy
      render json: { message: "Notícia removida com sucesso" }, status: :ok
    else
      render json: { error: "Notícia não encontrada" }, status: :not_found
    end
  end

  private

  def news_params
    params.require(:news).permit(:title, :source, :description, :image_url, :category, :link_url, :featured)
  end
end