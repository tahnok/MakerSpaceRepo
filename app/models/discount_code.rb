class DiscountCode < ActiveRecord::Base
  belongs_to :price_rule
  belongs_to :user
  validates :shopify_discount_code_id, presence: true
  validates :code, presence: true
end
