# frozen_string_literal: true

class PrinterIssuesController < StaffAreaController
  layout "staff_area"

  def index
    @issues = PrinterIssue.all.order(:printer_id)
    @issues_summary =
      @issues
        .filter(&:active)
        .group_by do |issue|
          PrinterIssue.summaries.values.detect do |s|
            issue.summary.include? s
          end || "Other"
        end

    respond_to do |format|
      format.html
      format.json { render json: { issues: @issues, summary: @issues_summary } }
    end
  end

  def show
    @issue = PrinterIssue.find_by(id: params[:id])
  end

  def new
    @issue ||= PrinterIssue.new
    @printers = Printer.show_options.all
    @issueSummary =
      @printers
        .filter_map do |printer|
          count = printer.count_printer_issues.count
          [printer.id, printer.count_printer_issues] if count.positive?
        end
        .to_h
  end

  def create
    printer = Printer.find_by(id: printer_issue_params[:printer_id])
    @issue =
      PrinterIssue.new(
        printer: printer,
        summary: printer_issue_params[:summary],
        description: printer_issue_params[:description],
        reporter: current_user,
        active: true
      )

    if @issue.save
      respond_to do |format|
        format.html { redirect_to @issue }
        format.json { head :no_content }
      end
    else
      new # set previous variables
      flash[
        :alert
      ] = "Failed to create issue: #{@issue.errors.full_messages.join("<br />")}".html_safe
      # All this to keep form data on error
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: flash, status: :unprocessable_entity }
      end
    end
  end

  def edit
    new
    @issue = PrinterIssue.find(params[:id])
    render :new, locals: { is_edit: true }
  end

  def update
    # Ideally, all updates happen from /printer_issues
    issue = PrinterIssue.find_by(id: params[:id])
    unless issue.update(printer_issue_params)
      flash[
        :alert
      ] = "Failed to update printer issue #{params[:id]}, #{issue.errors.full_messages.join(";")}"
      respond_to do |format|
        format.html { redirect_to printer_issues_path }
        format.json { render json: flash, status: :unprocessable_entity }
      end
    end
    respond_to do |format|
      format.html do
        if issue.active
          redirect_to issue
        else
          redirect_to printer_issues_path
        end
      end
      format.json { head :no_content }
    end
  end

  def destroy
    unless current_user.admin?
      redirect_to printer_issues_path
      return
    end
    success = PrinterIssue.find_by(id: params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to printer_issues_path,
                    status: :see_other,
                    alert: ("Failed to destroy issue" unless success)
      end
      format.json do
        if success
          head :no_content
        else
          render json: { alert: "Failed to destroy issue" }
        end
        render
      end
    end
  end

  private

  def printer_issue_params
    params.require(:printer_issue).permit(
      :printer_id,
      :summary,
      :description,
      :active
    )
  end
end
