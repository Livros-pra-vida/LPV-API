# Carrinho do usuário logado, salvo no banco. Os preços vêm sempre do catálogo.
class CartsController < ApplicationController
  before_action :authenticate_user!

  # GET /cart
  def show
    render json: resumo
  end

  # POST /cart/items   corpo: { "catalog_book_id": 3 }  ou  { "title": "Duna" }  (+ "quantity" opcional)
  # Se o livro já está no carrinho, soma a quantidade.
  def add
    livro = if params[:catalog_book_id].present?
      CatalogBook.find(params[:catalog_book_id])
    else
      CatalogBook.where("LOWER(title) = ?", params[:title].to_s.strip.downcase).first!
    end

    item = current_user.cart_items.find_or_initialize_by(catalog_book: livro)
    item.quantity = (item.persisted? ? item.quantity : 0) + quantidade_pedida(1)
    salvar(item, :created)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  # PATCH /cart/items/:id   corpo: { "quantity": 2 }
  def update_item
    item = current_user.cart_items.find(params.expect(:id))
    item.quantity = quantidade_pedida(item.quantity)
    salvar(item, :ok)
  end

  # DELETE /cart/items/:id
  def remove_item
    current_user.cart_items.find(params.expect(:id)).destroy!
    render json: resumo
  end

  private

  def quantidade_pedida(padrao)
    params[:quantity].present? ? params[:quantity].to_i : padrao
  end

  def salvar(item, status)
    if item.save
      render json: resumo, status: status
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def resumo
    itens = current_user.cart_items.includes(:catalog_book).order(:id)
    subtotal = itens.sum(&:subtotal)
    frete = itens.any? ? Order::SHIPPING : 0
    {
      items: itens.map(&:as_summary),
      count: itens.sum(&:quantity),
      subtotal: subtotal.to_f,
      shipping: frete.to_f,
      total: (subtotal + frete).to_f
    }
  end
end
