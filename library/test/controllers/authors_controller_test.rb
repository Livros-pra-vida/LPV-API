require "test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = authors(:one)
    @user = users(:one)
    @admin = users(:admin)
  end

  test "exige login" do
    get authors_url, as: :json
    assert_response :unauthorized
  end

  test "usuário logado lista, mostra e cria autores" do
    get authors_url, headers: auth_headers(@user), as: :json
    assert_response :success

    get author_url(@author), headers: auth_headers(@user), as: :json
    assert_response :success

    assert_difference("Author.count") do
      post authors_url, params: { author: { name: "Autora Nova", description: "Teste" } },
                        headers: auth_headers(@user), as: :json
    end
    assert_response :created
  end

  test "create sem nome devolve 422" do
    assert_no_difference("Author.count") do
      post authors_url, params: { author: { description: "sem nome" } },
                        headers: auth_headers(@user), as: :json
    end
    assert_response :unprocessable_content
  end

  test "usuário comum não edita nem apaga autor" do
    patch author_url(@author), params: { author: { name: "Outro" } },
                               headers: auth_headers(@user), as: :json
    assert_response :forbidden

    assert_no_difference("Author.count") do
      delete author_url(authors(:two)), headers: auth_headers(@user), as: :json
    end
    assert_response :forbidden
  end

  test "admin edita e apaga autor" do
    patch author_url(@author), params: { author: { name: "Renomeado" } },
                               headers: auth_headers(@admin), as: :json
    assert_response :success

    # Autor Dois tem livro (fixture), então cria um autor sem livros para apagar
    livre = Author.create!(name: "Sem livros")
    assert_difference("Author.count", -1) do
      delete author_url(livre), headers: auth_headers(@admin), as: :json
    end
    assert_response :no_content
  end
end
