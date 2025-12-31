class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [ :show, :edit, :update, :destroy, :pin, :unpin ]

  def index
    @notes = current_user.notes.order(pinned: :desc, updated_at: :desc)
  end

  def show
  end

  def new
    @note = current_user.notes.new
  end

  def create
    @note = current_user.notes.new(note_params)

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
    redirect_to notes_path, notice: t("notes.destroyed")
  end

  def pin
    @note.update(pinned: true)
    redirect_to notes_path, notice: t("notes.pinned")
  end

  def unpin
    @note.update(pinned: false)
    redirect_to notes_path, notice: t("notes.unpinned")
  end

  private
  def set_note
    @note = current_user.notes.includes(shared_withs: :user).find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content, :color, :pinned, tag_ids: [])
  end
end
