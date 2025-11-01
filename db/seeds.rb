# --------------------------
# Category 初期データ投入
# --------------------------

puts "【Category初期データ】投入を開始します..."

categories = [
  "アウター",
  "トップス ",
  "シャツ",
  "パンツ",
  "スカート",
  "ワンピース/オールインワン",
  "シューズ",
  "バッグ",
  "アクセサリー",
  "帽子",
  "その他"
]

categories.each do |name|
  # find_or_create_by! を使用して、存在しない場合のみ作成
  category = Category.find_or_create_by!(name: name)
  puts " -> カテゴリ「#{category.name}」を作成/確認しました"
end

puts "【Category初期データ】投入を完了しました。合計 #{Category.count} 件のカテゴリが登録されています。"