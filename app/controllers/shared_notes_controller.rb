class SharedNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [ :create, :destroy ]

  def index
    @shared_notes = current_user.shared_notes.includes(:user).order(updated_at: :desc)
  end

  def create
    recipient = User.find(params[:user_id])

    unless current_user.connected_with?(recipient)
      redirect_to @note, alert: t("shared_notes.not_connected")
      return
    end

    @shared_with = @note.shared_withs.build(user: recipient)

    if @shared_with.save
      redirect_to @note, notice: t("shared_notes.shared")
    else
      redirect_to @note, alert: t("shared_notes.share_failed")
    end
  end

  def destroy
    @shared_with = SharedWith.find(params[:id])

    unless @shared_with.note.user_id == current_user.id
      redirect_to root_path, alert: t("shared_notes.unauthorized")
      return
    end

    @shared_with.destroy
    redirect_to @shared_with.note, notice: t("shared_notes.unshared")
  end

  private
  def set_note
    @note = current_user.notes.find(params[:note_id])
  end
end
