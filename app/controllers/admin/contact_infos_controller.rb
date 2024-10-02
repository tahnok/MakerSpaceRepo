class Admin::ContactInfosController < AdminAreaController
  def index
    @contact_infos = ContactInfo.all.order(name: :asc)
  end

  def new
    @contact_info = ContactInfo.new
    #@contact_info.build_opening_hours
  end

  def create
    if Space.find_by(id: params[:contact_info][:space_id]).blank?
      params[:contact_info][:name] = params[:contact_info][:space_id]
      params[:contact_info][:space_id] = nil
    else
      params[:contact_info][:name] = Space.find(
        params[:contact_info][:space_id]
      ).name
    end
    contact_info = ContactInfo.new(contact_infos_params)
    if contact_info.save!
      redirect_to admin_contact_infos_path
      flash[:notice] = "You've successfully created a new Contact Info !"
    end
  end

  def edit
    @contact_info = ContactInfo.find(params[:id])
    #@contact_info.build_opening_hours if @contact_info.opening_hours.blank?
  end

  def update
    contact_info = ContactInfo.find(params[:id])
    if contact_info.update(contact_infos_params)
      flash[:notice] = "Contact Info updated"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to admin_contact_infos_path
  end

  def destroy
    contact_info = ContactInfo.find(params[:id])
    if contact_info.destroy
      flash[:notice] = "Contact Info Deleted"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to admin_contact_infos_path
  end

  def contact_infos_params
    params.require(:contact_info).permit(
      :name,
      :email,
      :address,
      :phone_number,
      :url,
      :show_hours,
      :space_id,
      # https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html
      # neat stuff really
      opening_hours_attributes: %i[
        id
        target_en
        target_fr
        notes_en
        notes_fr
        sunday_opening
        sunday_closing
        monday_opening
        monday_closing
        tuesday_opening
        tuesday_closing
        wednesday_opening
        wednesday_closing
        thursday_opening
        thursday_closing
        friday_opening
        friday_closing
        saturday_opening
        saturday_closing
        _destroy
      ]
    )
  end
end
