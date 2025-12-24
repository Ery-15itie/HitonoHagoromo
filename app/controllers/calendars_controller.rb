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
    @outfits = ActualOutfit.where(user: current_user)
                           .where(worn_on: @start_date..@end_date)
                           .includes(items: { image_attachment: :blob }, contacts: { avatar_attachment: :blob })

    # 同じ日・同じ時間帯のデータを配列 [outfit1, outfit2, ...] として取得
    @outfits_map = @outfits.group_by { |o| [o.worn_on, o.time_slot] }
  end
end
