class ApplicationController < ActionController::Base
  # Deviseの認証を全コントローラーに適用
  before_action :authenticate_user!
end
