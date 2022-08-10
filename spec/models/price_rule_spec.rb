require "rails_helper"
include ShopifyConcern

RSpec.describe PriceRule, type: :model do
  describe "Association" do
    context "has_many" do
      it { should have_many(:discount_codes) }
      it "dependent destroy: should destroy cc_moneys if destroyed" do
        price_rule = create(:price_rule_with_discount_codes)
        expect { price_rule.destroy }.to change { DiscountCode.count }.by(
          -price_rule.discount_codes.count
        )
      end
    end
  end

  describe "Validations" do
    context "presence" do
      it { should validate_presence_of(:shopify_price_rule_id) }
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:value) }
      it { should validate_presence_of(:cc) }
    end
  end

  describe "Methods Shopify" do
    before :context do
      @shopify_price_rule_id = PriceRule.create_price_rule("2$ Coupon", 2)
    end

    context "#create_price_rule from shopify" do
      it "should be an integer" do
        expect(@shopify_price_rule_id).to be_a_kind_of(Integer)
      end
    end

    context "#update_price_rule from shopify" do
      it "should update the price rule" do
        PriceRule.update_price_rule(@shopify_price_rule_id, "6$ Coupon", 6)
        shopify_price_rule = ShopifyAPI::PriceRule.find(@shopify_price_rule_id)
        expect(shopify_price_rule.value).to eq("-6.0")
        expect(shopify_price_rule.title).to eq("6$ Coupon")
      end
    end

    context "#delete_price_rule_from_shopify" do
      it "should be deleting the price rule" do
        shopify_price_rule_id = PriceRule.create_price_rule("7$ Coupon", 7)
        PriceRule.delete_price_rule_from_shopify(shopify_price_rule_id)
        expect {
          ShopifyAPI::PriceRule.find(shopify_price_rule_id)
        }.to raise_error(ActiveResource::ResourceNotFound)
      end
    end

    after :context do
      PriceRule.delete_price_rule_from_shopify(@shopify_price_rule_id)
    end
  end

  describe "Methods" do
    context "#has_discount_codes?" do
      before(:all) { @price_rule = create(:price_rule_with_discount_codes) }
      it "should return true" do
        expect(@price_rule.has_discount_codes?).to eq(true)
      end
      it "should return false" do
        @price_rule.discount_codes.destroy_all
        expect(@price_rule.has_discount_codes?).to eq(false)
      end
    end
  end
end
