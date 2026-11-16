require "test_helper"

class BookcaseTest < ActiveSupport::TestCase
  test "precisa de dono e de nome" do
    assert_not Bookcase.new(name: "Sem dono", limit: 5).valid?
    assert_not Bookcase.new(user: users(:one), limit: 5).valid?
  end

  test "limite precisa ser um inteiro positivo" do
    assert_not Bookcase.new(user: users(:one), name: "X", limit: 0).valid?
    assert_not Bookcase.new(user: users(:one), name: "X", limit: nil).valid?
  end

  test "nova estante recebe o limite padrão do banco" do
    assert_equal 50, Bookcase.new.limit
  end

  test "usuário só enxerga as próprias estantes" do
    assert_equal [ bookcases(:one) ], users(:one).bookcases.to_a
  end
end
