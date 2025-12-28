require 'rails_helper'

RSpec.describe ActualOutfit, type: :model do
  let(:user) { FactoryBot.create(:user) }

  # 事前にアイテムと人を作っておく
  let(:item_shirt) { FactoryBot.create(:item, user: user, name: "白シャツ") }
  let(:contact_friend) { FactoryBot.create(:contact, user: user, name: "親友A") }

  describe 'バリデーションと保存' do
    context '正常系' do
      it "日付、時間帯があれば有効であること" do
        outfit = FactoryBot.build(:actual_outfit, user: user)
        expect(outfit).to be_valid
      end

      it "人とアイテムを複数紐付けて保存できること" do
        outfit = FactoryBot.build(:actual_outfit, user: user)
        
        # 関連付け
        outfit.items << item_shirt
        outfit.contacts << contact_friend
        
        expect(outfit.save).to be_truthy
        
        # 保存後に正しく取得できるか確認
        reloaded_outfit = ActualOutfit.find(outfit.id)
        expect(reloaded_outfit.items).to include(item_shirt)
        expect(reloaded_outfit.contacts).to include(contact_friend)
      end
    end

    context '異常系' do
      it "日付がないと無効であること" do
        outfit = FactoryBot.build(:actual_outfit, user: user, worn_on: nil)
        outfit.valid?
        expect(outfit.errors[:worn_on]).to include("を入力してください")
      end

      it "時間帯がないと無効であること" do
        outfit = FactoryBot.build(:actual_outfit, user: user, time_slot: nil)
        outfit.valid?
        expect(outfit.errors[:time_slot]).to include("を入力してください")
      end
      
      it "メモが501文字以上だと無効であること" do
        outfit = FactoryBot.build(:actual_outfit, user: user, memo: "a" * 501)
        outfit.valid?
        expect(outfit.errors[:memo]).to include("は500文字以内で入力してください")
      end
    end
  end

  describe '★重要: 重複チェックロジックの検証' do
    # コントローラーで行っている「重複チェック」と同じクエリが正しく動くかテストします

    before do
      # 1ヶ月前に「親友A」と会った時に「白シャツ」を着ていた記録を作る
      @past_record = FactoryBot.create(:actual_outfit, 
        user: user, 
        worn_on: 1.month.ago, 
        items: [item_shirt], 
        contacts: [contact_friend]
      )
    end

    it "同じ相手(contact_friend)とアイテム(item_shirt)の組み合わせを見つけられること" do
      # 新しく登録しようとしているデータ（IDだけの配列を想定）
      search_contact_ids = [contact_friend.id]
      search_item_ids = [item_shirt.id]

      # 重複候補を検索するクエリシミュレーション
      # (joinsで関連テーブルを結合し、whereで条件一致を探す)
      duplicates = ActualOutfit
        .joins(:actual_outfit_contacts, :actual_outfit_items)
        .where(actual_outfit_contacts: { contact_id: search_contact_ids })
        .where(actual_outfit_items: { item_id: search_item_ids })
        .where.not(id: nil) # 新規作成時を想定

      expect(duplicates).to include(@past_record)
    end

    it "相手が違えば、重複とはみなされないこと" do
      other_friend = FactoryBot.create(:contact, user: user, name: "別人B")
      
      # アイテムは同じだが、相手が違う
      search_contact_ids = [other_friend.id]
      search_item_ids = [item_shirt.id]

      duplicates = ActualOutfit
        .joins(:actual_outfit_contacts, :actual_outfit_items)
        .where(actual_outfit_contacts: { contact_id: search_contact_ids })
        .where(actual_outfit_items: { item_id: search_item_ids })

      expect(duplicates).to be_empty
    end

    it "アイテムが違えば、重複とはみなされないこと" do
      other_item = FactoryBot.create(:item, user: user, name: "違う服")

      # 相手は同じだが、服が違う
      search_contact_ids = [contact_friend.id]
      search_item_ids = [other_item.id]

      duplicates = ActualOutfit
        .joins(:actual_outfit_contacts, :actual_outfit_items)
        .where(actual_outfit_contacts: { contact_id: search_contact_ids })
        .where(actual_outfit_items: { item_id: search_item_ids })

      expect(duplicates).to be_empty
    end
  end

  describe '削除時の挙動 (多対多)' do
    it "着用記録を削除しても、アイテムや人は削除されないこと" do
      outfit = FactoryBot.create(:actual_outfit, user: user)
      outfit.items << item_shirt
      outfit.contacts << contact_friend
      
      # 削除実行
      expect { outfit.destroy }.to change(ActualOutfit, :count).by(-1)
      
      # アイテムと人が残っているか確認
      expect(Item.exists?(item_shirt.id)).to be true
      expect(Contact.exists?(contact_friend.id)).to be true
    end
  end
end
