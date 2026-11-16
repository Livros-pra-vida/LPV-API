class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_catalog_book

  # PUT/PATCH /catalog_books/:catalog_book_id/rating   corpo: { "rating": { "score": 5 } }
  # Cria a avaliação do usuário logado ou troca a nota que ele já tinha dado.
  # O dono da avaliação é sempre o usuário do token (nunca vem do cliente).
  def update
    rating = @catalog_book.ratings.find_or_initialize_by(user_id: current_user.id)
    rating.score = rating_params[:score]

    if rating.save
      render json: summary
    else
      render json: { errors: rating.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    # Dois cliques simultâneos tentaram criar a avaliação ao mesmo tempo: o banco barrou o segundo.
    retry
  end

  # DELETE /catalog_books/:catalog_book_id/rating   (remove só a avaliação do próprio usuário)
  def destroy
    @catalog_book.ratings.where(user_id: current_user.id).destroy_all

    render json: summary
  end

  private
    def set_catalog_book
      @catalog_book = CatalogBook.find(params.expect(:catalog_book_id))
    end

    def rating_params
      params.expect(rating: [ :score ])
    end

    def summary
      @catalog_book.as_summary(my_score: @catalog_book.ratings.find_by(user_id: current_user.id)&.score)
    end
end
