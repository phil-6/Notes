module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    before_action :authenticate_user!
    helper_method :current_user, :user_signed_in?
  end

  private
  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user
    Current.user
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to sign_in_path, alert: t("authentication.sign_in_required") unless user_signed_in?
  end
end
