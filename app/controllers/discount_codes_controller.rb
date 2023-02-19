# frozen_string_literal: true

class DiscountCodesController < DevelopmentProgramsController
  before_action :check_and_set_price_rule_expiration, only: :create
  before_action :check_user_wallet, only: :create

  def index
    # Temporarily replaced with code for GoDaddy. This is the shopify version
    # user_discount_codes = current_user.coupon_codes
    user_discount_codes = current_user.discount_codes
    @discount_codes =
      user_discount_codes# .not_used
      # .includes(:price_rule)
      .
        order(created_at: :desc)
    # @expired_codes = user_discount_codes.used_code.includes(:price_rule)
    @expired_codes = []
    @all_discount_codes =
      # DiscountCode.includes(:price_rule).order(
      #   created_at: :desc
      # ) if current_user.admin?
      CouponCode.all.order(created_at: :desc) if current_user.admin?
  end

  def new
    @price_rules =
      # PriceRule.where("expired_at > ? OR expired_at IS NULL", DateTime.now)
      CouponCode.unclaimed
  end

  def create
    # cc_money_payment = CcMoney.make_new_payment(current_user, @price_rule.cc)
    cc_money_payment =
      CcMoney.make_new_payment(current_user, @price_rule.cc_cost)
    # if cc_money_payment.present?
    if cc_money_payment.present? && cc_money_payment.save
      #   @discount_code = current_user.discount_codes.new
      if @price_rule.update(user: current_user)
        flash[:notice] = "Discount Code created"
      else
        cc_money_payment.destroy
        flash[:alert] = "Discount Code not created properly!"
      end
    else
      flash[:alert] = "Payment not processed"
    end
    redirect_to discount_codes_path
    #   @discount_code.code = DiscountCode.generate_code
    #   @discount_code.price_rule = @price_rule
    #   shopify_discount_code = @discount_code.shopify_api_create_discount_code
    #   if shopify_discount_code.present?
    #     @discount_code.shopify_discount_code_id = shopify_discount_code.id
    #     @discount_code.usage_count = shopify_discount_code.usage_count
    #     if @discount_code.save
    #       cc_money_payment.update(discount_code: @discount_code)
    #       flash[:notice] = "Discount Code created"
    #     else
    #       cc_money_payment.destroy
    #       flash[:notice] = "Discount Code not created properly!"
    #     end
    #   else
    #     cc_money_payment.destroy
    #     flash[:notice] = "Shopify API not working"
    #   end
    # else
    #   flash[:notice] = "Payment not processed"
    # end
    # redirect_to discount_codes_path
  end

  private

  def check_and_set_price_rule_expiration
    # @price_rule = PriceRule.find_by(id: params[:price_rule_id])
    # unless @price_rule.expired_at.nil? || @price_rule.expired_at > DateTime.now
    #   flash[:alert] = "This coupon is expired"
    #   redirect_to new_discount_code_path
    # end
    @price_rule = CouponCode.find_by(id: params[:price_rule_id])

    unless @price_rule.user.nil?
      flash[:alert] = "This coupon is already claimed"
      redirect_to new_discount_code_path
    end
  end

  def webhook_params
    params.except(:controller, :action, :type)
  end

  def set_price_rule
    @price_rule = PriceRule.find_by(id: params[:price_rule_id])
  end

  def check_user_wallet
    current_user.update_wallet
    # unless current_user.wallet >= @price_rule.cc
    unless current_user.wallet >= @price_rule.cc_cost
      flash[:alert] = "Not enough CC points"
      redirect_back(fallback_location: root_path)
    end
  end
end
