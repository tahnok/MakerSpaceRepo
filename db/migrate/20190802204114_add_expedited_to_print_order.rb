class AddExpeditedToPrintOrder < ActiveRecord::Migration
  def change
    add_column :print_orders, :expedited, :boolean
  end
end
