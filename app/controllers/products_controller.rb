class ProductsController < ApplicationController
  before_action :require_login
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :end_auction ]
  before_action :ensure_user_has_full_address, only: [ :create ]
  before_action :ensure_no_orders, only: [ :destroy ]

  def index
    @products = Product.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @bids = @product.bids.order(created_at: :desc)
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

  def edit; end

  def update
    if @product.update(product_params)
      @bids = @product.bids

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

  def end_auction
    if @product.user == current_user
      @product.end_auction!
      redirect_to product_path(@product), notice: "Auction ended successfully!"
    else
      redirect_to product_path(@product), alert: "You are not authorized to end this auction."
    end
  end

  def search
    products_scope = params[:scope] == "my_auctions" ? current_user&.products : Product.all

    if params[:query].present? && params[:query].strip != ""
      @query = params[:query].strip
      @products = products_scope&.where("lower(title) LIKE ?", "%#{@query&.downcase}%")
    else
      @query = nil
      @products = products_scope
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def my_auctions
    @products = current_user&.products&.order(created_at: :desc)&.page(params[:page]).per(10)

    @my_search = true

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def ensure_no_orders
    if @product.orders.exists?
      redirect_to products_path, alert: "Cannot delete this product because it has existing orders."
    end
  end

  def ensure_user_has_full_address
    required_fields = %i[address country postal_code phone_number city]

    if required_fields.any? { |field| current_user.send(field).blank? }
      redirect_to edit_user_path(current_user),
                  alert: "Please complete your address information (address, country, postal code, phone number, and city) before creating a product."
    end
  end

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
