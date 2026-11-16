require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @book = books(:one)             # estante do usuário um
    @other_book = books(:two)       # estante do usuário dois
    @bookcase = bookcases(:one)     # limite 2, já tem 1 livro
    @other_bookcase = bookcases(:two)
  end

  def book_params(overrides = {})
    { book: { title: "Novo livro", rating: 4, author_id: authors(:one).id,
              bookcase_id: @bookcase.id }.merge(overrides) }
  end

  test "exige login" do
    get books_url, as: :json
    assert_response :unauthorized
  end

  test "index lista só os livros das estantes do usuário logado" do
    get books_url, headers: auth_headers(@user), as: :json
    assert_response :success

    ids = response.parsed_body.map { |b| b["id"] }
    assert_includes ids, @book.id
    assert_not_includes ids, @other_book.id
  end

  test "index filtra por autor sem vazar livros de outras pessoas" do
    get author_books_url(authors(:two)), headers: auth_headers(@user), as: :json
    assert_response :success
    assert_empty response.parsed_body
  end

  test "show de livro de outro usuário devolve 404" do
    get book_url(@other_book), headers: auth_headers(@user), as: :json
    assert_response :not_found
  end

  test "create na própria estante" do
    assert_difference("Book.count") do
      post books_url, params: book_params, headers: auth_headers(@user), as: :json
    end

    assert_response :created
    assert_equal "Autor Um", response.parsed_body["author_name"]
  end

  test "create na estante de outro usuário devolve 404" do
    assert_no_difference("Book.count") do
      post books_url, params: book_params(bookcase_id: @other_bookcase.id),
                      headers: auth_headers(@user), as: :json
    end

    assert_response :not_found
  end

  test "create respeita o limite da estante" do
    post books_url, params: book_params, headers: auth_headers(@user), as: :json
    assert_response :created # 2 de 2

    assert_no_difference("Book.count") do
      post books_url, params: book_params(title: "Um a mais"), headers: auth_headers(@user), as: :json
    end
    assert_response :unprocessable_content
  end

  test "update do título funciona mesmo com a estante cheia" do
    @bookcase.update!(limit: 1)

    patch book_url(@book), params: { book: { title: "Título novo" } },
                           headers: auth_headers(@user), as: :json
    assert_response :success
    assert_equal "Título novo", @book.reload.title
  end

  test "mover livro para estante de outro usuário devolve 404" do
    patch book_url(@book), params: { book: { bookcase_id: @other_bookcase.id } },
                           headers: auth_headers(@user), as: :json
    assert_response :not_found
    assert_equal @bookcase.id, @book.reload.bookcase_id
  end

  test "update de livro de outro usuário devolve 404" do
    patch book_url(@other_book), params: { book: { title: "Invadido" } },
                                 headers: auth_headers(@user), as: :json
    assert_response :not_found
  end

  test "destroy do próprio livro" do
    assert_difference("Book.count", -1) do
      delete book_url(@book), headers: auth_headers(@user), as: :json
    end

    assert_response :no_content
  end

  test "destroy de livro de outro usuário devolve 404" do
    assert_no_difference("Book.count") do
      delete book_url(@other_book), headers: auth_headers(@user), as: :json
    end

    assert_response :not_found
  end
end
