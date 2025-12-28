class CalendarsController < ApplicationController
  before_action :authenticate_user! # ログイン必須

  def show
    # 1. 基準日と範囲(月曜スタート)
    @current_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    @start_date = @current_date.beginning_of_week(:monday)
    @end_date   = @current_date.end_of_week(:monday)
    @week_days  = (@start_date..@end_date).to_a

    # 2. データ取得 (自分のデータのみ)
    outfits = current_user.actual_outfits
                          .where(worn_on: @start_date..@end_date)
                          .order(:start_time, :created_at)

    # 3. 【重要】日付を文字列化してキーにする
    # これにより、Date型とTimeWithZone型の不一致による表示漏れを防ぐ
    # キーの形式: ["2023-12-25", "morning"]
    @outfits_map = outfits.group_by { |o| [o.worn_on.to_date.to_s, o.time_slot] }
  end
end
