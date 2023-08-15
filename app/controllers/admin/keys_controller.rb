class Admin::KeysController < AdminAreaController
  before_action :set_key, only: %i[show edit destroy update]
  before_action :set_key_request, only: %i[approve approve_key deny_key]

  def index
    @keys = Key.order(created_at: :desc)
  end

  def show
    @files = (@key.key_request.nil?) ? @key.files : @key.key_request.files
  end

  def create
    @key = Key.new(key_params)
    update_files

    if @key.save
      flash[:notice] = "Successfully created key."
      redirect_to admin_keys_path
    else
      flash[:alert] = "Something went wrong while creating the key."
      render :new
    end
  end

  def new
    @key = Key.new
  end

  def update
    update_files

    if @key.update(key_params)
      flash[:notice] = "The key was successfully updated."
      redirect_to admin_keys_path
    else
      flash[:alert] = "Something went wrong while updating the key."
      render :edit
    end
  end

  def destroy
    if @key.destroy
      flash[:notice] = "Successfully deleted key."
    else
      flash[:alert] = "Something went wrong while trying to delete the key."
    end
    redirect_to admin_keys_path
  end

  def requests
    @key_requests =
      KeyRequest.where(status: :waiting_for_approval).order(created_at: :asc)
  end

  def approve_key
    key = Key.find(params[:key_id])

    if key.update(
         @key_request.get_approval_params.merge(
           status: :held,
           deposit_return_date: params[:deposit_return_date]
         )
       ) && @key_request.update(status: :approved)
      flash[:notice] = "Successfully approved key request."
    else
      flash[
        :alert
      ] = "Something went wrong when trying to approve the key request."
    end

    redirect_to requests_admin_keys_path
  end

  def deny_key
    if @key_request.update(status: :rejected)
      flash[:notice] = "Successfully denied key request."
    else
      flash[
        :alert
      ] = "Something went wrong when trying to deny the key request."
    end

    redirect_to requests_admin_keys_path
  end

  private

  def key_params
    params.require(:key).permit(
      :number,
      :user_id,
      :space_id,
      :supervisor_id,
      :status,
      :room,
      :deposit_return_date,
      :student_number,
      :phone_number,
      :emergency_contact,
      :emergency_contact_relation,
      :emergency_contact_phone_number
    )
  end

  def update_files
    if params[:delete_files].present?
      file_ids = params[:delete_files].split(",")

      @key.files.each { |f| f.purge if file_ids.include?(f.id.to_s) }
    end

    if params[:key][:files].present?
      params[:key][:files].each { |f| @key.files.attach(f) }
    end
  end

  def set_key
    @key = Key.find_by(id: params[:id])

    redirect_to admin_keys_path, alert: "The key id was not found." if @key.nil?
  end

  def set_key_request
    @key_request = KeyRequest.find_by(id: params[:id])

    if @key_request.nil?
      redirect_to admin_keys_path, alert: "The key request id was not found."
    end
  end
end
