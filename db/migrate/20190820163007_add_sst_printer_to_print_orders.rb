class AddSstPrinterToPrintOrders < ActiveRecord::Migration
  def change
    add_column :print_orders, :sst, :boolean
  end
end
