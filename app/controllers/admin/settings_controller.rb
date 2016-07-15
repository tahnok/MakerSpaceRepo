class Admin::SettingsController < AdminAreaController
  layout 'admin_area'
  
  def index
    @equip_option = EquipmentOption.new
    @cat_option = CategoryOption.new
  end
  
  def add_category
    if !params[:category_option][:name].present?
      flash[:alert] = "Invalid category name."
    else
      @cat_option = CategoryOption.new(cat_params)
      @cat_option.save
      flash[:notice] = "Category added successfully!"
    end
    redirect_to admin_settings_path
  end
  
  def rename_category
    if !params[:category_option][:name].present?
      flash[:alert] = "Invalid category name."
    elsif params[:rename_category]==""
      flash[:alert] = "Please select a category."
    else
      puts "params: #{params[:rename_category]}"
      CategoryOption.where(:id => params[:rename_category]).update_all(cat_params)
      flash[:notice] = "Category renamed successfully!"
    end
    redirect_to admin_settings_path
  end
  
  def remove_category
    if params[:remove_category]!=""
      CategoryOption.where(id: params[:remove_category]).destroy_all
      flash[:notice] = "Category removed successfully!"
    else
      flash[:alert] = "Please select a category."
    end
    redirect_to admin_settings_path
  end
  
  def cat_params
    params.require(:category_option).permit(:name)
  end
  
  def add_equipment
    if !params[:equipment_option][:name].present?
      flash[:alert] = "Invalid equipment name."
    else
      @equip_option = EquipmentOption.new(equip_params)
      @equip_option.save
      flash[:notice] = "Equipment added successfully!"
    end
    redirect_to admin_settings_path
  end
  
  def rename_equipment
    if !params[:equipment_option][:name].present?
      flash[:alert] = "Invalid equipment name."
    elsif params[:rename_equipment]==""
      flash[:alert] = "Please select a piece of equipment."
    else
      puts "params: #{params[:rename_equipment]}"
      EquipmentOption.where(:id => params[:rename_equipment]).update_all(equip_params)
      flash[:notice] = "Equipment renamed successfully!"
    end
    redirect_to admin_settings_path
  end
  
  def remove_equipment
    if params[:remove_equipment]!=""
      EquipmentOption.where(id: params[:remove_equipment]).destroy_all
      flash[:notice] = "Equipment removed successfully!"
    else
      flash[:alert] = "Please select a piece of equipment."
    end
    redirect_to admin_settings_path
  end
  
  def equip_params
    params.require(:equipment_option).permit(:name)
  end
end
