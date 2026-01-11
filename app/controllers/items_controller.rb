class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[index new create edit update suhada]

  # GET /items (メインのクローゼット)
  def index
    # is_private: false (シークレット以外) のみを表示
    @items = current_user.items.where(is_private: false).includes(image_attachment: :blob).includes(:category)
    apply_filters_and_sort
  end

  # GET /items/suhada (素肌を包むページ)
  def suhada
    # is_private: true (シークレット) のみを表示
    @items = current_user.items.where(is_private: true).includes(image_attachment: :blob).includes(:category)
    apply_filters_and_sort
    render :suhada
  end

  # GET /items/care (洗濯カゴ画面)
  def care
    # 「洗濯頻度が0より大きい(設定あり)」かつ「現在の着用回数 >= 設定頻度」のものを取得
    # これにより、頻度0（シューズ・アクセ等）はここに出てこなくなる
    @dirty_items = current_user.items
                               .where("wash_frequency > 0 AND wears_count >= wash_frequency")
                               .includes(image_attachment: :blob)
                               .order(wears_count: :desc)
  end

  # PATCH /items/wash (洗濯実行処理)
  def wash
    if params[:item_ids].present?
      # 選択されたアイテムを一括取得
      items_to_wash = current_user.items.where(id: params[:item_ids])
      
      count = 0
      items_to_wash.each do |item|
        # 1. 累積洗濯回数を +1
        item.total_washes += 1
        # 2. 現在の着用回数を 0 にリセット
        item.wears_count = 0
        if item.save
          count += 1
        end
      end
      
      # Turbo対応のため status: :see_other を追加
      redirect_to care_items_path, notice: "#{count}点の洗濯を記録しました！✨", status: :see_other
    else
      # Turbo対応のため status: :see_other を追加
      redirect_to care_items_path, alert: "洗濯するアイテムが選択されていません。", status: :see_other
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  def new
    @item = current_user.items.build
    # ★追加: デフォルトの洗濯頻度を「1回」にしておく
    @item.wash_frequency = 1
    
    # URLパラメータで ?is_private=true が来ていたら、初期値をONにする
    @item.is_private = true if params[:is_private] == 'true'
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      # 保存したアイテムがシークレットなら「素肌を包む」へ、通常なら「クローゼット」へリダイレクト
      redirect_path = @item.is_private ? suhada_items_path : @item
      redirect_to redirect_path, notice: "アイテムを登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /items/1
  def update
    # 画像削除処理
    if item_params[:remove_image] == '1' && @item.image.attached?
      @item.image.purge
    end

    # 画像更新のエラー対策
    update_params = item_params
    update_params.delete(:image) if update_params[:image].blank?

    if @item.update(update_params)
      # 更新後もそれぞれの部屋に戻るように調整
      redirect_path = @item.is_private ? suhada_items_path : @item
      redirect_to redirect_path, notice: "アイテム情報を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/1
  def destroy
    is_private_item = @item.is_private
    @item.destroy
    
    # 削除したアイテムがシークレットだったなら「素肌を包む」へ戻る
    redirect_path = is_private_item ? suhada_items_path : items_url
    redirect_to redirect_path, notice: "アイテムを削除しました。", status: :see_other
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
      params.require(:item).permit(
        :name, :description, :price, :category_id, :color, :image, :remove_image,
        :wash_frequency, :is_private, :wears_count, :total_washes
      )
    end

    # 共通のフィルタリング・ソート処理
    def apply_filters_and_sort
      if params[:category_id].present?
        @items = @items.where(category_id: params[:category_id])
      end

      case params[:sort]
      when 'price_high'
        @items = @items.order(price: :desc)
      when 'price_low'
        @items = @items.order(price: :asc)
      when 'oldest'
        @items = @items.order(created_at: :asc)
      else
        @items = @items.order(created_at: :desc)
      end
    end
end
