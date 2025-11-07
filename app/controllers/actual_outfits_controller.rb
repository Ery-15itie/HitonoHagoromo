class ActualOutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_form_data, only: [:new, :create] 
  before_action :set_actual_outfit, only: [:destroy]
  
  # 時間帯選択肢を定義 (3時間区切り、タイムテーブルの行に使用)
  # [DB保存値, 表示名]
  TIME_SLOTS = {
    't00_03' => '深夜 (00:00 - 02:59)',
    't03_06' => '早朝 (03:00 - 05:59)',
    't06_09' => '朝 (06:00 - 08:59)',
    't09_12' => '午前 (09:00 - 11:59)',
    't12_15' => '昼 (12:00 - 14:59)',
    't15_18' => '午後 (15:00 - 17:59)',
    't18_21' => '夕方 (18:00 - 20:59)',
    't21_00' => '夜 (21:00 - 23:59)'
  }.freeze


  # GET /outfits/calendar (週間カレンダー - カレンダー表示用)
  def index
    # Date.current.beginning_of_week(:monday) で、カレンダーの開始を月曜日に設定
    @start_date = params.fetch(:start_date, Date.current.beginning_of_week(:monday)).to_date
    @week_start = @start_date.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:monday)

    # その週内の全着用記録を取得し、日付をキーとするハッシュに変換
    @outfits_by_date = current_user.actual_outfits
                                   .includes(:item)
                                   .where(worn_on: @week_start..@week_end)
                                   .group_by(&:worn_on)
  end

  # GET /outfits (タイムテーブル表示 - メインビュー)
  def timeline
    @start_date = params.fetch(:start_date, Date.current.beginning_of_week(:monday)).to_date
    @week_start = @start_date.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:monday)
    
    # タイムテーブルビューのために、データを [日付][時間帯] で整理
    outfits = current_user.actual_outfits
                          .includes(:item)
                          .where(worn_on: @week_start..@week_end)
                          .order(:worn_on, :time_slot)
    
    @timeline_data = {}
    (@week_start..@week_end).each do |date|
      @timeline_data[date] = {}
      TIME_SLOTS.keys.each do |slot|
        @timeline_data[date][slot] = [] 
      end
    end

    outfits.each do |outfit|
      if outfit.time_slot.present? && TIME_SLOTS.key?(outfit.time_slot)
        @timeline_data[outfit.worn_on][outfit.time_slot] << outfit
      end
    end
    
    @time_slots = TIME_SLOTS
  end

  # GET /actual_outfits/new (アイテム選択フォーム)
  def new
    @actual_outfit = ActualOutfit.new
    # 日付と時間帯を初期値として設定
    @actual_outfit.worn_on = params[:worn_on].to_date if params[:worn_on].present?
    @actual_outfit.time_slot = params[:time_slot] if params[:time_slot].present?
    
    # フォーム用に時間帯の選択肢を準備
    @time_slot_options = TIME_SLOTS.map { |k, v| [v, k] }
  end

  # POST /actual_outfits
  def create
    @actual_outfit = current_user.actual_outfits.build(actual_outfit_params)

    # モデル側で重複チェックが行われる
    if @actual_outfit.save
      # 警告メッセージがあれば取得し、noticeに結合
      flash[:notice] = "着用を記録しました！"
      if @actual_outfit.errors.details[:base].present?
        # エラーメッセージをアラートとして表示
        flash[:alert] = @actual_outfit.errors.details[:base].map { |e| e[:message] }.join(' / ')
      end
      
      # 成功したら、記録した日付を含む週の**タイムラインビュー**に戻る
      redirect_to timeline_actual_outfits_path(start_date: @actual_outfit.worn_on.beginning_of_week(:monday))
    else
      flash.now[:alert] = "着用記録の作成に失敗しました。"
      # フォーム再描画のためにアイテム一覧と時間帯選択肢を準備
      @time_slot_options = TIME_SLOTS.map { |k, v| [v, k] }
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /actual_outfits/:id
  def destroy
    unless @actual_outfit.user_id == current_user.id
      # リダイレクト先をタイムラインビューに統一
      redirect_to timeline_actual_outfits_path, alert: "権限がありません。", status: :unauthorized
      return
    end
    
    # 削除後、**タイムラインビュー**の現在表示週に戻る
    @actual_outfit.destroy
    redirect_to timeline_actual_outfits_path(start_date: @actual_outfit.worn_on.beginning_of_week(:monday)), notice: "着用記録を削除しました。", status: :see_other
  end

  private

  # new/create アクションで使用するアイテム一覧とContact一覧を準備する
  def set_form_data
    @items = current_user.items.order(:name)
    # Contact一覧を取得
    @contacts = current_user.contacts.order(:name) 
  end
  
  def set_actual_outfit
    @actual_outfit = ActualOutfit.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 記録が見つからなかった場合、タイムラインビューにリダイレクト
    redirect_to timeline_actual_outfits_path, alert: "指定された着用記録が見つかりません。"
  end

  def actual_outfit_params
    # worn_on, item_id, time_slot, impression に加えて、contact_id を許可する 
    params.require(:actual_outfit).permit(:worn_on, :item_id, :time_slot, :impression, :contact_id) 
  end
end
