module ProductsHelper
  def seller?(product)
    product.user == current_user
  end
end
