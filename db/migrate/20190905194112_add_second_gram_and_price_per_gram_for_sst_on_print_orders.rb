class AddSecondGramAndPricePerGramForSstOnPrintOrders < ActiveRecord::Migration
  def change
    add_column :print_orders, :grams2, :float
    add_column :print_orders, :price_per_gram2, :float
  end
end
