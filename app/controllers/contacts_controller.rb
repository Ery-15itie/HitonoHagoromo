class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :history, :toggle_favorite]

  def index
    scope = current_user.contacts.includes(avatar_attachment: :blob).order(:name)

    if params[:query].present?
      search_term = "%#{params[:query]}%"
      scope = scope.where("LOWER(name) LIKE LOWER(?) OR LOWER(memo) LIKE LOWER(?)", search_term, search_term)
    end

    @contacts = scope.to_a
    @favorites = @contacts.select(&:is_favorite)
    @grouped_contacts = @contacts.reject(&:is_favorite).group_by(&:category)
    @categories_order = Contact.categories.keys
  end

  def new
    @contact = current_user.contacts.build
  end

  def create
    @contact = current_user.contacts.build(contact_params)

    if @contact.save
      redirect_to contacts_path, notice: "ご縁のある人（#{@contact.name}）を登録しました。"
    else
      flash.now[:alert] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # 全ての履歴（詳細リスト用）
    @outfits = @contact.actual_outfits
                       .includes(items: { image_attachment: :blob }, contacts: { avatar_attachment: :blob })
                       .order(worn_on: :desc)
    
    # 「最後に会った日」表示用（今日以前の日付の中で最新のもの）
    @last_met_outfit = @contact.actual_outfits
                               .where('worn_on <= ?', Date.today)
                               .order(worn_on: :desc)
                               .first
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "情報を更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    contact_name = @contact.name
    @contact.destroy
    redirect_to contacts_url, notice: "（#{contact_name}）を削除しました。", status: :see_other
  end
  
  def history
    @history_outfits = @contact.actual_outfits
                               .includes(items: { image_attachment: :blob }, contacts: { avatar_attachment: :blob })
                               .order(worn_on: :desc, time_slot: :desc)
  end

  def toggle_favorite
    @contact.update(is_favorite: !@contact.is_favorite)
    redirect_back(fallback_location: contacts_path)
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to contacts_path, alert: "データが見つかりません。", status: :not_found
  end

  def contact_params
    params.require(:contact).permit(:name, :category, :memo, :avatar, :is_favorite)
  end
end
