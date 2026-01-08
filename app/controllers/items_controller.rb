class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[index new create edit update]

  # GET /items
  def index
    # ★variant_records の警告を避けるため、シンプルな includes に変更
    @items = current_user.items.includes(image_attachment: :blob).includes(:category)

    # 2. カテゴリ絞り込み
    if params[:category_id].present?
      @items = @items.where(category_id: params[:category_id])
    end

    # 3. 並べ替え
    case params[:sort]
    when 'price_high'
      @items = @items.order(price: :desc)
    when 'price_low'
      @items = @items.order(price: :asc)
    when 'oldest'
      @items = @items.order(created_at: :asc)
    else
      @items = @items.order(created_at: :desc) # デフォルト
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  def new
    @item = current_user.items.build
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to @item, notice: "アイテムを登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /items/1
  def update
    # ★追加: 「画像削除」フラグが立っていたら、画像を削除（パージ）する
    if item_params[:remove_image] == '1' && @item.image.attached?
      @item.image.purge
    end

    # --- 画像更新のエラー対策 ---
    update_params = item_params
    # 画像フィールドが空で送信された場合（変更なしの場合）、既存の画像を消さないようにパラメータから除外
    update_params.delete(:image) if update_params[:image].blank?

    if @item.update(update_params)
      redirect_to @item, notice: "アイテム情報を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    redirect_to items_url, notice: "アイテムを削除しました。", status: :see_other
  end

  private

    def set_categories
      @categories = Category.order(:id)
    end

    def set_item
      @item = current_user.items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to items_url, alert: "アイテムが見つからないか、アクセス権がありません。"
    end

    def item_params
      # ★修正: :remove_image を許可リストに追加
      params.require(:item).permit(:name, :description, :price, :category_id, :color, :image, :remove_image)
    end
end
