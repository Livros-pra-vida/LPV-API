@books = Book.includes(:author, :bookcase).order(created_at: :desc)
```[cite: 21]

Ainda está lá o **`:author`** dentro do `includes`! Como o modelo `Book` no banco usa a chave estrangeira `author_id` mas o ActiveRecord não tem a associação `has_many` ou `belongs_to :author` configurada exatamente com esse nome exato no model, o Rails crasha com erro 500 na hora em que o frontend tenta carregar o catálogo[cite: 20, 21]. É por isso que nenhum livro aparecia!

Vamos corrigir isso agora de forma definitiva, eliminando o `.includes(:author)` e buscando o autor com segurança absoluta via código Ruby.

---

### Copie e substitua todo o conteúdo do seu `app/controllers/books_controller.rb` por este:

```ruby
class BooksController < ApplicationController
  # GET /books
  def index
    # Buscamos apenas os livros e estantes para evitar qualquer erro de associação do ActiveRecord
    @books = Book.includes(:bookcase).order(created_at: :desc)
    
    books_json = @books.map do |book|
      # Resolve o nome do autor com segurança absoluta (via relação ou ID direto)
      nome_autor = if book.respond_to?(:author) && book.author.respond_to?(:name)
        book.author&.name
      elsif book.respond_to?(:author_id) && book.author_id.present?
        Author.find_by(id: book.author_id)&.name
      end

      book.as_json.merge(author: nome_autor || "Desconhecido")
    end

    render json: books_json
  end

  # POST /books
  def create
    nome_autor = params.dig(:book, :author)
    
    # Busca ou cria o autor na tabela 'authors'
    autor = Author.find_or_create_by!(name: nome_autor) if nome_autor.present?
    
    # Garante uma estante padrão para satisfazer a relação do banco
    estante = Bookcase.first || Bookcase.create!(name: "Estante Geral da Loja", limit: 500)

    book = Book.new(
      title: params.dig(:book, :title),
      genre: params.dig(:book, :genre),
      price: params.dig(:book, :price),
      image_url: params.dig(:book, :image_url),
      description: params.dig(:book, :description),
      rating: params.dig(:book, :rating) || 5,
      featured: false,
      author_id: autor&.id,
      bookcase_id: estante.id
    )

    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /books/:id
  def update
    book = Book.find_by(id: params[:id])
    if book
      book.update_column(:featured, params[:book][:featured])
      render json: book, status: :ok
    else
      render json: { error: "Livro não encontrado no PostgreSQL" }, status: :not_found
    end
  end

  # DELETE /books/:id
  def destroy
    book = Book.find_by(id: params[:id])
    if book
      book.destroy
      render json: { message: "Livro removido com sucesso" }, status: :ok
    else
      render json: { error: "Livro não encontrado no PostgreSQL" }, status: :not_found
    end
  end
end