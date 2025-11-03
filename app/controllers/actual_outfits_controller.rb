class ActualOutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_form_data, only: [:new, :create] # 新しい set_form_data に変更
  before_action :set_actual_outfit, only: [:destroy]

  # GET /outfits (週間カレンダー)
  def index
    # 表示する週の開始日を決定 (URLパラメータ 'start_date' があればそれを使用, なければ今週の日曜日)
    # Date.current.beginning_of_week(:monday) で、カレンダーの開始を月曜日に設定
    @start_date = params.fetch(:start_date, Date.current.beginning_of_week(:monday)).to_date
    @week_start = @start_date.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:monday)

    # その週内の全着用記録を取得し、日付をキーとするハッシュに変換
    # 例: { Date.new(2025, 11, 3) => [log1, log2], ... }
    @outfits_by_date = current_user.actual_outfits
                                   .includes(:item)
                                   .where(worn_on: @week_start..@week_end)
                                   .group_by(&:worn_on)
  end

  # GET /actual_outfits/new (アイテム選択フォーム)
  def new
    @actual_outfit = ActualOutfit.new
    # カレンダーから日付が選ばれた場合、その日付を初期値として設定
    @actual_outfit.worn_on = params[:worn_on].to_date if params[:worn_on].present?
  end

  # POST /actual_outfits
  def create
    @actual_outfit = current_user.actual_outfits.build(actual_outfit_params)

    if @actual_outfit.save
      # 成功したら、記録した日付を含む週のカレンダーに戻る
      redirect_to actual_outfits_path(start_date: @actual_outfit.worn_on.beginning_of_week(:sunday)), notice: "着用を記録しました！"
    else
      flash.now[:alert] = "着用記録の作成に失敗しました。"
      # フォーム再描画のためにアイテム一覧を準備
      @items = current_user.items.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /actual_outfits/:id
  def destroy
    unless @actual_outfit.user_id == current_user.id
      redirect_to actual_outfits_path, alert: "権限がありません。", status: :unauthorized
      return
    end
    
    # 削除後、カレンダーの現在表示週に戻る
    redirect_to actual_outfits_path(start_date: @actual_outfit.worn_on.beginning_of_week(:sunday)), notice: "着用記録を削除しました。", status: :see_other
  end

  private

  # new/create アクションで使用するアイテム一覧を準備する
  def set_form_data
    @items = current_user.items.order(:name)
  end
  
  def set_actual_outfit
    @actual_outfit = ActualOutfit.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to actual_outfits_path, alert: "指定された着用記録が見つかりません。"
  end

  def actual_outfit_params
    # worn_on と item_id の両方を許可
    params.require(:actual_outfit).permit(:worn_on, :item_id) 
  end
end
