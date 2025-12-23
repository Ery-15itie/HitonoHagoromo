class CalendarsController < ApplicationController
  def show
    # パラメータの日付、なければ今日
    @current_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current

    # 週の始まりと終わり（月曜始まり）
    @start_date = @current_date.beginning_of_week(:monday)
    @end_date = @current_date.end_of_week(:monday)

    # 1週間分の日付オブジェクトの配列
    @week_days = (@start_date..@end_date).to_a

    # その週のデータを取得
    # itemのimage, contactのavatarの画像データそのもの(blob)までまとめて取得して高速化
    @outfits = ActualOutfit.where(user: current_user)
                           .where(worn_on: @start_date..@end_date)
                           .includes(item: { image_attachment: :blob }, contact: { avatar_attachment: :blob })

    # ビューで扱いやすくするため、日付と時間帯のペアでハッシュ化する
    # { [Date: 2025-12-22, "morning"] => <ActualOutfit>, ... } の形式にする
    @outfits_map = @outfits.index_by { |o| [o.worn_on, o.time_slot] }
  end
end
