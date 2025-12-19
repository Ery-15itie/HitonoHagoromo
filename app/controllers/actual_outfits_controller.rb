class ActualOutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_actual_outfit, only: %i[edit update destroy]
  
  # 人間の生活リズムに合わせた4区分
  TIME_SLOTS = {
    'morning'   => '🌅 朝 (06:00 - 11:59)',
    'daytime'   => '☀️ 昼 (12:00 - 17:59)',
    'night'     => '🌙 夜 (18:00 - 23:59)',
    'midnight'  => '🛌 深夜 (00:00 - 05:59)'
  }.freeze

  # GET /actual_outfits (全記録リスト)
  def index
    @actual_outfits = current_user.actual_outfits.includes(:item, :contact).order(worn_on: :desc)
  end

  # GET /actual_outfits/timeline (カレンダー/タイムテーブル)
  def timeline
    # 表示する週の開始日を決定（パラメータがなければ今日を含む週の月曜日）
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @week_start = @start_date.beginning_of_week
    @week_end   = @start_date.end_of_week
    
    # タイムテーブル用のデータを取得
    # ハッシュ構造: date -> time_slot -> [records]
    @timeline_data = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
    
    records = current_user.actual_outfits
                          .where(worn_on: @week_start..@week_end)
                          .includes(:item, :contact)
                          .with_attached_snapshot # 画像のN+1対策

    records.each do |record|
      @timeline_data[record.worn_on][record.time_slot] << record
    end
    
    @time_slots = TIME_SLOTS
  end

  # GET /actual_outfits/new
  def new
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
      # 保存成功 -> カレンダーへ戻る
      redirect_to timeline_actual_outfits_path(start_date: @actual_outfit.worn_on), notice: '着用記録を保存しました'
    else
      # 失敗 (重複警告など) -> 入力画面を表示し直す
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
      redirect_to timeline_actual_outfits_path(start_date: @actual_outfit.worn_on), notice: '記録を更新しました'
    else
      prepare_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /actual_outfits/:id
  def destroy
    date = @actual_outfit.worn_on
    @actual_outfit.destroy
    redirect_to timeline_actual_outfits_path(start_date: date), notice: '記録を削除しました', status: :see_other
  end

  private

  def set_actual_outfit
    @actual_outfit = current_user.actual_outfits.find(params[:id])
  end

  # フォームのプルダウン用データを取得
  def prepare_form_options
    @items = current_user.items.order(:category_id, :name)
    @contacts = current_user.contacts.order(:name)
    @time_slot_options = TIME_SLOTS.map { |k, v| [v, k] }
  end

  def actual_outfit_params
    params.require(:actual_outfit).permit(
      :worn_on, 
      :time_slot, 
      :worn_time,
      :impression, 
      :contact_id, 
      :force_create, # 重複警告を無視するフラグ
      :snapshot,
      item_ids: []   # 複数アイテム選択対応
    )
  end
end
