class PreferencesController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(preference_params)
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    else
      redirect_back fallback_location: root_path, alert: t("preferences.update_failed")
    end
  end

  private
  def preference_params
    params.require(:user).permit(:dark_mode)
  end
end
