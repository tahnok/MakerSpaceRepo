class AddHoursInPrintOrders < ActiveRecord::Migration
  def change
    add_column :print_orders, :hours, :float
  end
end
