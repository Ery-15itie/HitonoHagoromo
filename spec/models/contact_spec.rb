require 'rails_helper'

RSpec.describe Contact, type: :model do
  # FactoryBotで作ったユーザーデータを利用
  let(:user) { FactoryBot.create(:user) }

  describe 'バリデーションと保存' do
    context '正常系' do
      it "名前とカテゴリがあれば有効であること" do
        # FactoryBotの :contact を使う
        contact = FactoryBot.build(:contact, user: user)
        expect(contact).to be_valid
      end

      it "メモがなくても有効であること" do
        contact = FactoryBot.build(:contact, user: user, memo: nil)
        expect(contact).to be_valid
      end
    end

    context '異常系' do
      it "名前がないと無効であること" do
        contact = FactoryBot.build(:contact, user: user, name: nil)
        contact.valid?
        expect(contact.errors[:name]).to include("を入力してください")
      end

      it "名前が51文字以上だと無効であること" do
        contact = FactoryBot.build(:contact, user: user, name: "a" * 51)
        contact.valid?
        expect(contact.errors[:name]).to include("は50文字以内で入力してください")
      end
    end
  end

  describe 'カテゴリラベルの表示ロジック' do
    # ここが今回一番重要な「大切な人優先ロジック」のテストです

    context 'お気に入り(is_favorite)が true の場合' do
      it "カテゴリが何であっても「大切な人」と表示されること" do
        # trait :important を使って「大切な人」データを作成
        # カテゴリはあえて「家族」にしておく
        contact = FactoryBot.create(:contact, :important, :family, user: user)
        
        # 結果は「家族」ではなく「大切な人」になるはず
        expect(contact.category_label).to eq "大切な人"
      end
    end

    context 'お気に入り(is_favorite)が false の場合' do
      it "設定したカテゴリ名（家族）が表示されること" do
        # trait :family を使用
        contact = FactoryBot.create(:contact, :family, user: user)
        expect(contact.category_label).to eq "家族"
      end

      it "設定したカテゴリ名（仕事）が表示されること" do
        # trait :work を使用
        contact = FactoryBot.create(:contact, :work, user: user)
        expect(contact.category_label).to eq "仕事"
      end
      
      it "設定したカテゴリ名（友達）が表示されること" do
        # デフォルトは友達
        contact = FactoryBot.create(:contact, user: user)
        expect(contact.category_label).to eq "友だち"
      end
    end
  end
end
