class ProductsController < ApplicationController
  before_action :require_login
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = Product.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    if @product.save
      redirect_to products_path, notice: "Product successfully added!"
    else
      flash.now[:alert] = "Something went wrong"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product successfully updated!"
    else
      flash.now[:alert] = "Something went wrong"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      respond_to do |format|
        format.html { redirect_to products_path, notice: "Product successfully deleted!" }
        format.turbo_stream { head :ok }
      end
    else
      flash.now[:alert] = "Failed to delete product!"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title,
                                    :description,
                                    :starting_bid,
                                    :auction_duration,
                                    :product_image)
  end
end
