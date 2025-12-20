class ContactsController < ApplicationController
  before_action :authenticate_user! # ログイン必須
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :history, :toggle_favorite]

  # GET /contacts
  def index
    # 1. 基本の取得
    scope = current_user.contacts.with_attached_avatar.order(:name)

    # 2. 検索機能
    if params[:query].present?
      search_term = "%#{params[:query]}%"
      # 名前 または メモ に一致するものを探す (LOWERで大文字小文字無視)
      scope = scope.where("LOWER(name) LIKE LOWER(?) OR LOWER(memo) LIKE LOWER(?)", search_term, search_term)
    end

    # 3. データを配列として確定させる
    all_contacts = scope.to_a

    # 4. お気に入りとグループ分け
    @favorites = all_contacts.select(&:is_favorite)
    @grouped_contacts = all_contacts.reject(&:is_favorite).group_by(&:group)
    
    # 5. グループの表示順序設定
    # モデルのEnum定義順 (10, 20, 30, ..., 99) がそのまま適用されるようにする
    # その他(99)は一番最後
    @groups_order = Contact.groups.keys
  end

  # GET /contacts/new
  def new
    @contact = current_user.contacts.build
  end

  # POST /contacts
  def create
    @contact = current_user.contacts.build(contact_params)

    if @contact.save
      redirect_to contacts_path, notice: "ご縁のある人（#{@contact.name}）を登録しました。"
    else
      flash.now[:alert] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # GET /contacts/:id
  def show
    # @contact は set_contact で取得済み
  end

  # GET /contacts/:id/edit
  def edit
    # @contact は set_contact で取得済み
  end

  # PATCH/PUT /contacts/:id
  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "ご縁のある人（#{@contact.name}）の情報を更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /contacts/:id
  def destroy
    contact_name = @contact.name
    @contact.destroy
    redirect_to contacts_url, notice: "ご縁のある人（#{contact_name}）を削除しました。", status: :see_other
  end
  
  # GET /contacts/:id/history
  def history
    @history_outfits = @contact.actual_outfits
                               .includes(:item)
                               .order(worn_on: :desc, time_slot: :desc)
  end

  # PATCH /contacts/:id/toggle_favorite
  def toggle_favorite
    @contact.update(is_favorite: !@contact.is_favorite)
    redirect_back(fallback_location: contacts_path)
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to contacts_path, alert: "指定された連絡先が見つかりません。", status: :not_found
  end

  # ストロングパラメータ
  def contact_params
    params.require(:contact).permit(:name, :memo, :group, :avatar, :is_favorite)
  end
end
