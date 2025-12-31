class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [ :show, :edit, :update, :destroy, :pin, :unpin ]

  def index
    # Combine owned notes and shared notes
    owned_notes = current_user.notes.includes(:user, :rich_text_content)
    shared_notes = current_user.shared_notes.includes(:user, :rich_text_content)
    @notes = (owned_notes + shared_notes).sort_by { |n| [ n.pinned? ? 0 : 1, -n.updated_at.to_i ] }
  end

  def show
  end

  def new
    @note = current_user.notes.new
  end

  def create
    @note = current_user.notes.new(note_params)
    @note.version_user = current_user

    if @note.save
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.created") }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @note.version_user = current_user
    if @note.update(note_params)
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.updated") }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_path, notice: t("notes.destroyed") }
      format.turbo_stream
    end
  end

  def pin
    @note.update(pinned: true)
    respond_to do |format|
      format.html { redirect_to notes_path, notice: t("notes.pinned") }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@note), partial: "note_card", locals: { note: @note }) }
    end
  end

  def unpin
    @note.update(pinned: false)
    respond_to do |format|
      format.html { redirect_to notes_path, notice: t("notes.unpinned") }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@note), partial: "note_card", locals: { note: @note }) }
    end
  end

  private
  def set_note
    # Allow access to owned notes and shared notes
    owned_note = current_user.notes.includes(shared_withs: :user).find_by(id: params[:id])
    shared_note = current_user.shared_notes.includes(:user, shared_withs: :user).find_by(id: params[:id])
    @note = owned_note || shared_note
    redirect_to notes_path, alert: "Note not found" unless @note
  end

  def note_params
    params.require(:note).permit(:title, :content, :color, :pinned, tag_ids: [])
  end
end
