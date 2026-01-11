class ActualOutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_actual_outfit, only: %i[show edit update destroy]

  def index
    @actual_outfits = current_user.actual_outfits
                                  .includes(:items, :contacts)
                                  .order(worn_on: :desc)
  end

  def show
  end

  def new
    @actual_outfit = current_user.actual_outfits.build(
      worn_on: params[:worn_on] || Date.current,
      time_slot: params[:time_slot]
    )
    prepare_form_options
  end

  def edit
    prepare_form_options
  end

  def create
    @actual_outfit = current_user.actual_outfits.build(actual_outfit_params)
    
    if @actual_outfit.save
      # 紐付いたアイテムの着用回数(wears_count)を +1 する
      @actual_outfit.items.each do |item|
        item.increment!(:wears_count)
      end

      redirect_to calendar_path(start_date: @actual_outfit.worn_on), notice: '着用記録を保存しました'
    else
      prepare_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @actual_outfit.update(actual_outfit_params)
      redirect_to calendar_path(start_date: @actual_outfit.worn_on), notice: '記録を更新しました'
    else
      prepare_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    date = @actual_outfit.worn_on
    @actual_outfit.destroy
    redirect_to calendar_path(start_date: date), notice: '記録を削除しました', status: :see_other
  end

  # 重複チェック用
  def check_duplicates
    item_ids = params[:item_ids] || []
    contact_ids = params[:contact_ids] || []
    current_id = params[:id]
    lookback_period = 3.months.ago.to_date

    if item_ids.empty? || contact_ids.empty?
      render json: { duplicates: [] }
      return
    end

    duplicates = current_user.actual_outfits
                             .joins(:contacts, :items)
                             .where(contacts: { id: contact_ids })
                             .where(items: { id: item_ids })
                             .where('worn_on >= ?', lookback_period)
                             .where.not(id: current_id)
                             .distinct
                             .includes(:contacts, :items)
                             .order(worn_on: :desc)

    results = duplicates.map do |outfit|
      {
        date: outfit.worn_on.strftime("%Y/%m/%d"),
        time_slot: I18n.t("enums.actual_outfit.time_slot.#{outfit.time_slot}"),
        overlapping_contacts: outfit.contacts.select { |c| contact_ids.include?(c.id.to_s) }.map(&:name),
        overlapping_items: outfit.items.select { |i| item_ids.include?(i.id.to_s) }.map(&:name)
      }
    end
    render json: { duplicates: results }
  end

  private

  def set_actual_outfit
    @actual_outfit = current_user.actual_outfits.find(params[:id])
  end

  def prepare_form_options
    @items = current_user.items.with_attached_image.order(created_at: :desc)
    @contacts = current_user.contacts.with_attached_avatar.order(:name)
  end

  def actual_outfit_params
    params.require(:actual_outfit).permit(
      :worn_on, :time_slot, :start_time, :title, :color, :memo, :image,
      item_ids: [], contact_ids: []
    )
  end
end
