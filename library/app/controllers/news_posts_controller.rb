# Novidades: qualquer pessoa lê; só administradores publicam, editam e apagam.
class NewsPostsController < ApplicationController
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :require_admin!, only: %i[ create update destroy ]

  # GET /news_posts   { noticias: [...], lancamentos: [...] }  (admin recebe também quem publicou)
  def index
    admin = current_user&.admin? || false
    render json: {
      noticias: NewsPost.noticias.includes(:user).limit(60).map { |n| n.as_summary(include_author: admin) },
      lancamentos: NewsPost.lancamentos.where("release_date >= ?", 1.month.ago.to_date).includes(:user)
                           .map { |n| n.as_summary(include_author: admin) }
    }
  end

  # POST /news_posts   corpo: { "news_post": { "title": ..., "kind": "noticia", "category": "livros", ... } }
  def create
    post = NewsPost.new(news_params.merge(user: current_user))
    NewsPost.transaction do
      # Só uma notícia fica no banner de destaque por vez.
      NewsPost.where(featured: true).update_all(featured: false) if post.featured?
      post.save!
    end
    registrar_acao_admin("publicou a novidade", post)
    render json: post.as_summary(include_author: true), status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { errors: post.errors.full_messages }, status: :unprocessable_content
  end

  # PATCH /news_posts/:id
  def update
    post = NewsPost.find(params.expect(:id))
    NewsPost.transaction do
      post.assign_attributes(news_params)
      NewsPost.where(featured: true).where.not(id: post.id).update_all(featured: false) if post.featured?
      post.save!
    end
    registrar_acao_admin("editou a novidade", post)
    render json: post.as_summary(include_author: true)
  rescue ActiveRecord::RecordInvalid
    render json: { errors: post.errors.full_messages }, status: :unprocessable_content
  end

  # DELETE /news_posts/:id
  def destroy
    post = NewsPost.find(params.expect(:id))
    post.destroy!
    registrar_acao_admin("apagou a novidade", post)
    head :no_content
  end

  private
    def news_params
      params.expect(news_post: [ :kind, :category, :title, :summary, :source_name, :source_url, :image_url, :featured, :release_date ])
    end
end
