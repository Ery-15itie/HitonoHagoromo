class ContactsController < ApplicationController
  before_action :authenticate_user! # ログイン必須
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :history]

  # GET /contacts
  def index
    # ログインユーザーの連絡先を名前順に取得
    @contacts = current_user.contacts.order(:name)
  end

  # GET /contacts/new
  def new
    @contact = current_user.contacts.build
  end

  # POST /contacts
  def create
    @contact = current_user.contacts.build(contact_params)

    if @contact.save
      # 成功したら、連絡先一覧へリダイレクト
      redirect_to contacts_path, notice: "会う人（#{@contact.name}）を登録しました。"
    else
      # 失敗したら、フォームを再表示
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
      # 成功したら、詳細ページへリダイレクト
      redirect_to @contact, notice: "会う人（#{@contact.name}）の情報を更新しました。"
    else
      # 失敗したら、フォームを再表示
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /contacts/:id
  def destroy
    contact_name = @contact.name
    @contact.destroy
    # 成功したら、連絡先一覧へリダイレクト
    redirect_to contacts_url, notice: "会う人（#{contact_name}）を削除しました。", status: :see_other
  end
  
  # GET /contacts/:id/history
  # 特定の会う人と会った時の着用実績履歴を表示する
  def history
    # ログインユーザーの、このContact_idを持つ着用実績を新しい順に取得
    @history_outfits = @contact.actual_outfits
                               .includes(:item)
                               .order(worn_on: :desc, time_slot: :desc)
    
    # history.html.erb にて、@contact, @history_outfits を利用
  end


  private

  # URLの:idに基づいてContactを取得し、権限チェックを行う
  def set_contact
    @contact = current_user.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 存在しない、または他のユーザーのContactの場合
    redirect_to contacts_path, alert: "指定された連絡先が見つかりません。", status: :not_found
  end

  # ストロングパラメータ
  def contact_params
    params.require(:contact).permit(:name, :memo)
  end
end
