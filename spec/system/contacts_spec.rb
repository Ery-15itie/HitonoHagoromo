require 'rails_helper'

RSpec.describe "Contacts", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    # ログイン画面へ
    visit new_user_session_path
    
    # match: :first をつけて、最初に見つかったフォームに入力させる(レスポンシブデザイン対応)
    fill_in 'user_email', with: user.email, match: :first
    fill_in 'user_password', with: user.password, match: :first
    
    # ボタンも同様に複数ある可能性があるので、最初に見つかったものを押す
    click_button 'ログイン', match: :first
  end

  describe '一覧画面の動作' do
    let!(:contact_family) { FactoryBot.create(:contact, :family, name: '家族太郎', user: user) }
    let!(:contact_other) { FactoryBot.create(:contact, :other, name: 'その他花子', user: user) }

    it '「その他」グループが「家族」より下に表示される' do
      visit contacts_path
      
      # 画面上のテキストの出現順序をチェック
      expect(page.body.index('家族太郎')).to be < page.body.index('その他花子')
    end

    it '検索機能で絞り込みができる' do
      visit contacts_path
      
      # 検索フォームに入力してEnter
      fill_in 'query', with: '家族', match: :first
      find('input[name="query"]', match: :first).send_keys(:enter)

      expect(page).to have_content '家族太郎'
      expect(page).not_to have_content 'その他花子'
    end
  end

  describe '新規登録' do
    it '新しい人を登録できる' do
      visit new_contact_path

      fill_in '名前 (必須)', with: 'テスト新入', match: :first
      select '友達', from: 'グループ', match: :first
      fill_in 'contact[memo]', with: 'テストメモ', match: :first
      
      click_button '友だち登録する', match: :first

      expect(page).to have_content 'ご縁のある人（テスト新入）を登録しました'
      expect(page).to have_content 'テスト新入'
    end
  end
end
