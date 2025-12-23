require 'rails_helper'

RSpec.describe Contact, type: :model do
  # ユーザーを作成しておく (letで定義すると、itの中で user を呼ぶだけで使えるようになります)
  let(:user) { FactoryBot.create(:user) }

  describe 'バリデーションの確認' do
    it '名前、ユーザー、グループがあれば有効であること' do
      # FactoryBot.build(:contact) でダミーデータを作成
      contact = FactoryBot.build(:contact, user: user)
      expect(contact).to be_valid
    end

    it '名前がない場合は無効であること' do
      contact = FactoryBot.build(:contact, name: nil, user: user)
      contact.valid?
      # エラーメッセージが含まれているかチェック
      expect(contact.errors[:name]).to include("を入力してください")
    end

    it '名前が51文字以上の場合は無効であること' do
      contact = FactoryBot.build(:contact, name: "a" * 51, user: user)
      contact.valid?
      expect(contact.errors[:name]).to include("は50文字以内で入力してください")
    end
  end

  describe 'グループ順序（Enum）の確認' do
    it '「その他(other)」グループは、数値の99として保存されること' do
      # trait :other を使ってその他グループのデータを作成
      contact = FactoryBot.create(:contact, :other, user: user)
      
      # DBに保存されている「生の数値」を確認 (read_attribute_before_type_cast)
      # これが 99 なら、「その他」が一番後ろに来る設定が成功しています
      expect(contact.read_attribute_before_type_cast(:group)).to eq 99
    end

    it '「家族(family)」グループは、数値の10であること' do
      contact = FactoryBot.create(:contact, :family, user: user)
      expect(contact.read_attribute_before_type_cast(:group)).to eq 10
    end
  end
end
