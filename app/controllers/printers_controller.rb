# frozen_string_literal: true

class PrintersController < StaffAreaController
  layout "staff_area"

  before_action :ensure_admin, only: %i[index add_printer remove_printer]

  def index
    @printer = Printer.new
    @printer_models =
      PrinterType
        .all
        .order(name: :asc)
        .map do |pt|
          [pt.name + (pt.short_form.blank? ? "" : " (#{pt.short_form})"), pt.id]
        end
  end

  def update
    Printer.find_by(id: params[:id]).update(printer_params)
    redirect_to printers_path
  end

  def add_printer
    if params[:printer][:number].blank? || params[:model_id].blank?
      flash[:alert] = "Invalid printer model or number"
    else
      number = params[:printer][:number]

      @printer = Printer.new(number: number, printer_type_id: params[:model_id])
      if @printer.save
        flash[:notice] = "Printer added successfully!"
      else
        flash[:alert] = "Printer number already exists"
      end
    end
    # pass the model to keep selection
    redirect_to printers_path(model_id: params[:model_id])
  end

  def remove_printer
    if params[:remove_printer] != ""
      Printer.where(id: params[:remove_printer]).destroy_all
      flash[:notice] = "Printer removed successfully!"
    else
      flash[:alert] = "Please select a Printer."
    end
    redirect_to printers_path
  end

  def staff_printers
    @printers = Printer.all
    @list_users =
      User
        .joins(lab_sessions: :space)
        .where(
          "lab_sessions.sign_out_time > ? AND spaces.name = ?",
          Time.zone.now,
          "Makerspace"
        )
        .order("lab_sessions.sign_out_time DESC")
        .uniq
        .pluck(:name, :id)
    @list_users.unshift(%w[Clear clear])
    @printer_types = PrinterType.all.order("lower(name) ASC")
    # Sort by length then by value, solves the "1 then 10" issue
    @printers_by_type =
      Printer
        .all
        .sort_by { |p| [p.number.length, p.number] }
        .group_by(&:printer_type)
  end

  def staff_printers_updates
    @printer_types = PrinterType.all.order("lower(name) ASC")
  end

  def link_printer_to_user
    printer_id = params[:printer][:printer_id]
    last_session = Printer.get_last_number_session(printer_id)
    user_id = params[:printer][:user_id]
    if printer_id.blank? || user_id.blank?
      flash[:alert] = "Please add both printer and user."
    elsif user_id == "clear" && last_session.update(in_use: false)
      flash[:notice] = "Cleared the user."
    elsif PrinterSession.create(
          printer_id: printer_id,
          user_id: user_id,
          in_use: true
        )
      if !last_session.nil? && last_session.in_use?
        last_session.update(in_use: false)
      end
      flash[:notice] = "Printer Session Created"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to staff_printers_printers_path
  end

  def send_print_failed_message_to_user
    msg_params = params[:print_failed_message]
    print_owner = User.find_by(username: msg_params[:username])
    printer = Printer.find_by(id: msg_params[:printer_number])

    if printer.nil?
      flash[:alert] = "Error sending message, printer not found"
    elsif print_owner.nil?
      flash[:alert] = "Error sending message, username not found"
    else
      MsrMailer.print_failed(
        printer,
        print_owner,
        msg_params[:staff_notes]
      ).deliver_now

      flash[:notice] = "Email sent successfully"
    end

    if msg_params[:sent_from] == "updates"
      redirect_to staff_printers_updates_printers_url
    elsif msg_params[:sent_from] == "printers"
      redirect_to staff_printers_printers_url #(anchor: 'failedPrintHeader')
    end
  end

  private

  def printer_params
    if current_user.admin?
      params.require(:printer).permit(:number, :maintenance)
    else
      params.require(:printer).permit(:maintenance)
    end
  end

  def ensure_admin
    @user = current_user

    unless @user.admin?
      flash[:alert] = "You cannot access this area"
      redirect_back(fallback_location: root_path)
    end
  end
end
