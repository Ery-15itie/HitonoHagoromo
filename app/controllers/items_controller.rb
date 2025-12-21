class ItemsController < ApplicationController
  # ユーザーがサインインしていることを確認
  before_action :authenticate_user!
  
  # 特定のアイテムを操作するアクションの前に、アイテムを特定
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  
  # フォームおよび一覧画面のサイドバーで必要なカテゴリ一覧を事前に取得
  before_action :set_categories, only: [:index, :new, :create, :edit, :update]

  # GET /items
  def index
    # ベースとなるクエリ：現在のユーザーのアイテムを取得
    # .with_attached_image で画像のN+1問題を回避
    # .includes(:category) でカテゴリのN+1問題を回避
    @items = current_user.items.with_attached_image.includes(:category)

    # 1. カテゴリ絞り込み機能
    # パラメータに category_id が存在する場合、そのカテゴリで絞り込む
    if params[:category_id].present?
      @items = @items.where(category_id: params[:category_id])
    end

    # 2. 並べ替え機能
    # パラメータ sort の値によって並び順を変更
    case params[:sort]
    when 'price_high'
      @items = @items.order(price: :desc)       # 価格が高い順
    when 'price_low'
      @items = @items.order(price: :asc)        # 価格が安い順
    when 'oldest'
      @items = @items.order(created_at: :asc)   # 登録が古い順
    else
      @items = @items.order(created_at: :desc)  # デフォルト: 新しい順
    end
  end

  # GET /items/1 (Show)
  def show
    # @item は set_item で設定済み
  end

  # GET /items/new (New)
  def new
    @item = current_user.items.build 
  end

  # POST /items (Create)
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to @item, notice: "アイテムが正常に登録されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /items/1/edit (Edit)
  def edit
    # @item は set_item で設定済み
  end

  # PATCH/PUT /items/1 (Update)
  def update
    # ---  画像未選択時のエラー対策 ---
    # パラメータを操作可能な変数に格納
    update_params = item_params

    # 画像データが空文字("")として送られてきた場合、更新対象から削除する
    # これにより ActiveSupport::MessageVerifier::InvalidSignature を防ぐ
    update_params.delete(:image) if update_params[:image].blank?

    if @item.update(update_params)
      redirect_to @item, notice: "アイテム情報が正常に更新されました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/1 (Destroy)
  def destroy
    @item.destroy
    redirect_to items_url, notice: "アイテムが削除されました。", status: :see_other
  end

  private
    # Categoryモデルからカテゴリ一覧を取得する
    def set_categories
      @categories = Category.all.order(:id)
    end
    
    # URLのIDからアイテムを特定し、かつユーザーの所有権を確認する
    def set_item
      @item = current_user.items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to items_url, alert: "指定されたアイテムが見つからないか、アクセス権がありません。"
    end

    # ストロングパラメータ
    def item_params
      params.require(:item).permit(:name, :image, :category_id, :description, :price, :color)
    end
end
