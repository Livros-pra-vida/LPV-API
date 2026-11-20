require "test_helper"

class BookcasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other = users(:two)
    @bookcase = bookcases(:one)       # do usuário um
    @other_bookcase = bookcases(:two) # do usuário dois
  end

  test "exige login" do
    get bookcases_url, as: :json
    assert_response :unauthorized
  end

  test "index lista só as estantes do usuário logado" do
    get bookcases_url, headers: auth_headers(@user), as: :json
    assert_response :success

    ids = response.parsed_body.map { |b| b["id"] }
    assert_includes ids, @bookcase.id
    assert_not_includes ids, @other_bookcase.id
  end

  test "show da própria estante traz os livros com o nome do autor" do
    get bookcase_url(@bookcase), headers: auth_headers(@user), as: :json
    assert_response :success

    body = response.parsed_body
    assert_equal 1, body["books"].size
    assert_equal "Autor Um", body["books"].first["author_name"]
    assert_not body.key?("user_id")
  end

  test "show da estante de outro usuário devolve 404" do
    get bookcase_url(@other_bookcase), headers: auth_headers(@user), as: :json
    assert_response :not_found
  end

  test "create vincula a estante ao usuário logado e ignora user_id enviado" do
    assert_difference("@user.bookcases.count") do
      post bookcases_url,
           params: { bookcase: { name: "Nova estante", limit: 10, user_id: @other.id } },
           headers: auth_headers(@user), as: :json
    end

    assert_response :created
    assert_equal @user, Bookcase.find(response.parsed_body["id"]).user
  end

  test "create sem nome devolve 422" do
    assert_no_difference("Bookcase.count") do
      post bookcases_url, params: { bookcase: { limit: 10 } }, headers: auth_headers(@user), as: :json
    end

    assert_response :unprocessable_content
  end

  test "dois usuários podem ter estantes com o mesmo nome, o mesmo usuário não" do
    post bookcases_url, params: { bookcase: { name: "Favoritos", limit: 5 } },
                        headers: auth_headers(@other), as: :json
    assert_response :created

    post bookcases_url, params: { bookcase: { name: "favoritos", limit: 5 } },
                        headers: auth_headers(@user), as: :json
    assert_response :unprocessable_content
  end

  test "update da própria estante" do
    patch bookcase_url(@bookcase), params: { bookcase: { name: "Renomeada", limit: 3 } },
                                   headers: auth_headers(@user), as: :json
    assert_response :success
    assert_equal "Renomeada", @bookcase.reload.name
  end

  test "update da estante de outro usuário devolve 404 e não altera nada" do
    patch bookcase_url(@other_bookcase), params: { bookcase: { name: "Invadida" } },
                                         headers: auth_headers(@user), as: :json
    assert_response :not_found
    assert_equal "Segredos do Dois", @other_bookcase.reload.name
  end

  test "destroy da própria estante apaga também os livros" do
    assert_difference([ "Bookcase.count", "Book.count" ], -1) do
      delete bookcase_url(@bookcase), headers: auth_headers(@user), as: :json
    end

    assert_response :no_content
  end

  test "destroy da estante de outro usuário devolve 404" do
    assert_no_difference("Bookcase.count") do
      delete bookcase_url(@other_bookcase), headers: auth_headers(@user), as: :json
    end

    assert_response :not_found
  end
end
