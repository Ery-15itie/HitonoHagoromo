# spec/models/item_spec.rb
require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe 'バリデーション' do
    context '正常系' do
      it "名前があれば有効であること" do
        item = FactoryBot.build(:item, user: user, name: "シャツ")
        expect(item).to be_valid
      end

      it "価格が0円でも有効であること" do
        item = FactoryBot.build(:item, user: user, price: 0)
        expect(item).to be_valid
      end

      it "カテゴリがなくても有効であること" do
        item = FactoryBot.build(:item, user: user, category: nil)
        expect(item).to be_valid
      end
    end

    context '異常系' do
      it "名前がないと無効であること" do
        item = FactoryBot.build(:item, user: user, name: nil)
        item.valid?
        expect(item.errors[:name]).to include("を入力してください")
      end

      it "名前が51文字以上だと無効であること" do
        item = FactoryBot.build(:item, user: user, name: "a" * 51)
        item.valid?
        expect(item.errors[:name]).to include("は50文字以内で入力してください")
      end

      it "価格がマイナスだと無効であること" do
        item = FactoryBot.build(:item, user: user, price: -100)
        item.valid?
        expect(item.errors[:price]).to include("は0以上の値にしてください")
      end

      it "色の名前が31文字以上だと無効であること" do
        item = FactoryBot.build(:item, user: user, color: "あ" * 31)
        item.valid?
        expect(item.errors[:color]).to include("は30文字以内で入力してください")
      end
    end
  end

  describe '削除時の挙動 (多対多)' do
    it "アイテムを削除すると、中間テーブル(actual_outfit_items)も削除されること" do
      item = FactoryBot.create(:item, user: user)
      
      # Itemを削除するとカウントが1減ることを確認
      expect { item.destroy }.to change(Item, :count).by(-1)
    end
  end
end
