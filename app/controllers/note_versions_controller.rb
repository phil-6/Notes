class NoteVersionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note
  before_action :set_version, only: [ :show, :restore ]

  def index
    @versions = @note.versions.includes(:created_by).ordered
  end

  def show
  end

  def restore
    @note.version_user = current_user
    @version.restore_to_note

    respond_to do |format|
      format.html { redirect_to note_versions_path(@note), notice: t("versions.restored") }
      format.turbo_stream
    end
  end

  private
  def set_note
    @note = current_user.notes.find(params[:note_id])
  end

  def set_version
    @version = @note.versions.find(params[:id])
  end
end
