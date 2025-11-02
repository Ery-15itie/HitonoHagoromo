class ItemsController < ApplicationController
  # ユーザーがサインインしていることを確認 (全てのItemsControllerアクションに適用)
  before_action :authenticate_user!
  
  # 特定のアイテムを操作するアクションの前に、アイテムを特定
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  
  # フォームで必要なカテゴリ一覧を事前に取得
  before_action :set_categories, only: [:new, :create, :edit, :update]

  # GET /items
  # アイテム一覧の表示
  def index
    # 現在ログインしているユーザーのアイテムのみを取得
    # .includes(:category) でN+1問題を回避し、効率的にカテゴリ名も取得
    @items = current_user.items.includes(:category).order(created_at: :desc)
  end

  # GET /items/1 (Show)
  # アイテム詳細の表示
  def show
    # @item は set_item で設定済み
  end

  # GET /items/new (New)
  # 新規作成フォームの表示
  def new
    # 現在のユーザーに関連付けてItemを新規作成
    @item = current_user.items.build 
  end

  # POST /items (Create)
  # アイテムの新規作成処理
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to @item, notice: "アイテムが正常に登録されました。"
    else
      # バリデーションエラー時はnewテンプレートを再描画
      render :new, status: :unprocessable_entity
    end
  end

  # GET /items/1/edit (Edit)
  # 編集フォームの表示
  def edit
    # @item は set_item で設定済み
  end

  # PATCH/PUT /items/1 (Update)
  # アイテムの更新処理
  def update
    if @item.update(item_params)
      redirect_to @item, notice: "アイテム情報が正常に更新されました。", status: :see_other
    else
      # バリデーションエラー時はeditテンプレートを再描画
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/1 (Destroy)
  # アイテムの削除処理
  def destroy
    @item.destroy
    redirect_to items_url, notice: "アイテムが削除されました。", status: :see_other
  end

  private
    # Categoryモデルからカテゴリ一覧を取得する
    def set_categories
      @categories = Category.all.order(:name)
    end
    
    # URLのIDからアイテムを特定し、かつユーザーの所有権を確認する
    def set_item
      # 現在のユーザーに紐づくアイテムのみを検索し、セキュリティを確保
      @item = current_user.items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # アイテムが見つからない、または他人のアイテムにアクセスした場合
      redirect_to items_url, alert: "指定されたアイテムが見つからないか、アクセス権がありません。"
    end

    # ストロングパラメータ (許可された属性のみを許可)
    def item_params
      params.require(:item).permit(:name, :category_id, :description, :price, :color)
    end
end
