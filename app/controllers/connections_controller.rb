class ConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_connection, only: [ :accept, :reject, :destroy ]

  def index
    @connections = current_user.connected_users
    @pending_requests = current_user.pending_connection_requests
    @sent_requests = current_user.initiated_connections.pending
  end

  def create
    recipient = User.find_by(email: connection_params[:email])

    unless recipient
      redirect_to connections_path, alert: t("connections.user_not_found")
      return
    end

    if recipient == current_user
      redirect_to connections_path, alert: t("connections.cannot_connect_self")
      return
    end

    if current_user.connected_with?(recipient)
      redirect_to connections_path, alert: t("connections.already_connected")
      return
    end

    @connection = current_user.initiated_connections.build(user_2: recipient)

    if @connection.save
      redirect_to connections_path, notice: t("connections.request_sent")
    else
      redirect_to connections_path, alert: t("connections.request_failed")
    end
  end

  def accept
    @connection.accept!
    redirect_to connections_path, notice: t("connections.accepted")
  end

  def reject
    @connection.reject!
    redirect_to connections_path, notice: t("connections.rejected")
  end

  def destroy
    @connection.destroy
    redirect_to connections_path, notice: t("connections.removed")
  end

  private
  def set_connection
    @connection = Connection.find(params[:id])
    unless @connection.user_1_id == current_user.id || @connection.user_2_id == current_user.id
      redirect_to connections_path, alert: t("connections.unauthorized")
    end
  end

  def connection_params
    params.permit(:email)
  end
end
