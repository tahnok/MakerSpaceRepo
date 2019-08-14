class PrintOrdersController < ApplicationController
  before_action :current_user
  before_action :signed_in

  def index
    #TODO: Too much logic in index.html.erb
      if (@user.staff? || @user.admin?)
        @print_order = PrintOrder.all.order(created_at: :desc)
      else
        @print_order = @user.print_orders.order(created_at: :desc)
      end
    end

    def new
      @print_order = PrintOrder.new
    end

    def create
      @print_order = PrintOrder.create(print_order_params)
      redirect_to print_orders_path
    end

    def update
      @print_order = PrintOrder.find(params[:id])
      @user = @print_order.user
      @print_order.update(print_order_params)

      if params[:print_order][:approved] == "true"
        MsrMailer.send_print_quote(@user, @print_order.quote, params[:print_order][:staff_comments], @print_order.file_file_name).deliver_now
      elsif params[:print_order][:approved] == "false"
        MsrMailer.send_print_disapproval(@user, params[:print_order][:staff_comments], @print_order.file_file_name).deliver_now
      elsif params[:print_order][:printed] == "true"
        MsrMailer.send_print_finished(@user, @print_order.file_file_name).deliver_now
        MsrMailer.send_invoice(@user.name, @print_order.quote, @print_order.id, @print_order.order_type).deliver_now
      end

      redirect_to print_orders_path
    end

    def destroy
      @print_order = PrintOrder.find(params[:id])
      @print_order.destroy
      redirect_to print_orders_path
    end

    def edit
      @print_order = PrintOrder.find(params[:id])
    end

    private

    def print_order_params
      params.require(:print_order).permit(:user_id, :final_file, :timestamp_approved, :order_type, :comments, :approved, :printed, :file, :quote, :user_approval, :staff_comments, :staff_id, :expedited)
    end

end
