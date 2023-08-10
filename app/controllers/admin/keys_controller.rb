class Admin::KeysController < AdminAreaController
  before_action :set_key, only: %i[edit destroy update]

  def index
    @keys = Key.all.order(created_at: :desc)
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

  private

  def key_params
    params.require(:key).permit(
      :number,
      :user_id,
      :space_id,
      :supervisor_id,
      :status
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
    @key = Key.find(params[:id])
  end
end
