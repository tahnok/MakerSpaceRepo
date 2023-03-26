# frozen_string_literal: true

class DiscountCode < ApplicationRecord
  include ShopifyConcern
  belongs_to :price_rule, optional: true
  belongs_to :user, optional: true
  has_many :cc_moneys, dependent: :destroy
  validates :shopify_discount_code_id, presence: true
  validates :code, presence: true
  scope :used_code, -> { where(usage_count: 1) }
  scope :not_used, -> { where(usage_count: 0) }

  def self.generate_code
    code = SecureRandom.hex(15)
    code = SecureRandom.hex(15) while code_exist?(code)
    code
  end

  def self.code_exist?(code)
    DiscountCode.exists?(code: code)
  end

  def self.start_session
    start_shopify_session
  end

  def status
    usage_count == 0 ? "Not used" : "Used"
  end

  def shopify_api_create_discount_code
    DiscountCode.start_session
    shopify_discount_code = ShopifyAPI::DiscountCode.new
    shopify_discount_code.prefix_options[
      :price_rule_id
    ] = price_rule.shopify_price_rule_id
    shopify_discount_code.code = code
    shopify_discount_code.save
    shopify_discount_code
  end

  def delete_discount_code_from_shopify
    DiscountCode.start_session
    shopify_discount_code =
      ShopifyAPI::DiscountCode.where(
        id: shopify_discount_code_id,
        price_rule_id: price_rule.shopify_price_rule_id
      ).last
    shopify_discount_code.destroy
  end
end
