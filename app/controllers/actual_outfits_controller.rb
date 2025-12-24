class ActualOutfitsController < ApplicationController
  before_action :authenticate_user!
  # show アクションは個別にデータを取得するため、ここには含めない
  before_action :set_actual_outfit, only: %i[edit update destroy]

  # GET /actual_outfits
  def index
    @actual_outfits = current_user.actual_outfits
                                  .includes(:items, :contacts)
                                  .order(worn_on: :desc)
  end

  # GET /actual_outfits/:id
  # 詳細画面用のデータを取得
  def show
    @actual_outfit = current_user.actual_outfits
                                 .includes(items: { image_attachment: :blob }, contacts: { avatar_attachment: :blob })
                                 .find(params[:id])
  end

  # GET /actual_outfits/new
  def new
    # カレンダーの「＋」ボタンから渡された worn_on, time_slot を初期値にする
    @actual_outfit = current_user.actual_outfits.build(
      worn_on: params[:worn_on] || Date.current,
      time_slot: params[:time_slot]
    )
    prepare_form_options
  end

  # POST /actual_outfits
  def create
    @actual_outfit = current_user.actual_outfits.build(actual_outfit_params)

    if @actual_outfit.save
      # ★成功時: カレンダーの該当週を表示する
      redirect_to calendar_path(start_date: @actual_outfit.worn_on), notice: '着用記録を保存しました'
    else
      # 失敗時: フォームを再表示
      prepare_form_options
      render :new, status: :unprocessable_entity
    end
  end

  # GET /actual_outfits/:id/edit
  def edit
    prepare_form_options
  end

  # PATCH/PUT /actual_outfits/:id
  def update
    if @actual_outfit.update(actual_outfit_params)
      # ★成功時: カレンダーに戻る
      redirect_to calendar_path(start_date: @actual_outfit.worn_on), notice: '記録を更新しました'
    else
      prepare_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /actual_outfits/:id
  def destroy
    date = @actual_outfit.worn_on
    @actual_outfit.destroy
    # ★削除時: カレンダーに戻る
    redirect_to calendar_path(start_date: date), notice: '記録を削除しました', status: :see_other
  end

  private

  def set_actual_outfit
    @actual_outfit = current_user.actual_outfits.find(params[:id])
  end

  # フォームの選択肢用データ
  def prepare_form_options
    @items = Item.all 
    @contacts = Contact.all 
  end

  def actual_outfit_params
    params.require(:actual_outfit).permit(
      :worn_on, 
      :time_slot, 
      :start_time,     # 時間 (HH:MM)
      :title,          # 予定タイトル
      :color,          # ラベル色
      :memo,           # メモ
      :image,          # 当日の写真
      item_ids: [],    # 服 (複数選択)
      contact_ids: []  # 人 (複数選択)
    )
  end
end
