# frozen_string_literal: true
require "date"
class Admin::ShiftsController < AdminAreaController
  layout "admin_area"

  before_action :set_default_space
  before_action :set_shifts, only: %i[edit update destroy]

  def index
    @staff =
      User.where(
        id: StaffSpace.where(space_id: @space_id).pluck(:user_id)
      ).pluck(:name, :id)
    @spaces = Space.all.where(id: SpaceStaffHour.all.pluck(:space_id))
    @space_id = @user.space_id || Space.first.id
    @colors = []

    StaffSpace
      .joins(:user)
      .where(space_id: @space_id)
      .order("users.name")
      .each do |staff|
        @colors << {
          id: staff.user.id,
          name: staff.user.name,
          color: staff.color
        }
      end
  end

  def shifts
    @staff =
      User.where(
        id: StaffSpace.where(space_id: @space_id).pluck(:user_id)
      ).pluck(:name, :id)
    @spaces = Space.all.where(id: SpaceStaffHour.all.pluck(:space_id))
    get_colours(Date.today)
  end

  def refresh_hours
    get_colours(Date.parse(params[:date]))
    render partial: "admin/shifts/user_colours"
  end

  def get_colours(date)
    @colors = []
    StaffSpace
      .joins(:user)
      .where(space_id: @space_id)
      .order("users.name")
      .each do |staff|
        hours =
          Shift
            .joins(:shifts_users)
            .where(
              shifts_users: {
                user_id: staff.user.id
              },
              space_id: @space_id,
              start_datetime: date.beginning_of_week..date.end_of_week
            )
            .sum do |shift|
              (shift.end_datetime - shift.start_datetime).to_i / 3600
            end
        @colors << {
          id: staff.user.id,
          name: staff.user.name + " (#{"%.2f" % hours} hours)",
          color: staff.color
        }
      end
  end
  def pending_shifts
    render partial: "admin/shifts/pending_shifts"
  end

  def confirm_shifts
    Shift.where(space_id: @user.space_id, pending: true).update(pending: false)
    redirect_to shifts_admin_shifts_path,
                notice: "Shifts have been successfully confirmed!"
  end

  def clear_pending_shifts
    Shift.where(space_id: @user.space_id, pending: true).destroy_all
    redirect_to shifts_admin_shifts_path,
                notice: "Shifts have been successfully cleared!"
  end

  def create
    if params[:shift].present? && params[:user_id].present?
      @shift = Shift.new(shift_params.merge(space_id: @space_id))
      params[:user_id].each { |user_id| @shift.users << User.find(user_id) }
    elsif params[:start_datetime].present? &&
          params[:start_datetime].present? && params[:user_id].present?
      start_date = DateTime.parse(params[:start_datetime])
      end_date = DateTime.parse(params[:start_datetime])
      @shift =
        Shift.new(
          space_id: @space_id,
          start_datetime: start_date,
          end_datetime: end_date,
          reason: params[:reason]
        )
      @shift.users << User.where(id: params[:user_id])
    else
      respond_to do |format|
        format.html { render :new }
        format.json do
          render json: {
                   error: "Missing params"
                 },
                 status: :unprocessable_entity
        end
      end
    end

    respond_to do |format|
      if @shift.save
        format.html do
          redirect_to shifts_admin_shifts_path,
                      notice: "The shift has been successfully created."
        end
        format.json do
          render json: {
                   id: @shift.id,
                   name: @shift.return_event_title,
                   color:
                     hex_color_to_rgba(
                       @shift.color(@space_id),
                       @shift.pending? ? 0.7 : 1
                     ),
                   start: @shift.start_datetime,
                   end: @shift.end_datetime,
                   className:
                     @shift.users.first.name.strip.downcase.gsub(" ", "-")
                 }
        end
      else
        format.html { render :new }
        format.json do
          render json: @shift.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    puts params
    if params[:shift].present?
      respond_to do |format|
        if @shift.update(shift_params)
          format.html do
            redirect_to shifts_admin_shifts_path,
                        notice: "The shift has been successfully updated."
          end
          format.json { render json: { status: "ok" } }
        else
          format.html { render :edit }
          format.json do
            render json: @shift.errors, status: :unprocessable_entity
          end
        end
      end
    elsif params[:start_datetime].present? && params[:end_datetime].present?
      start_date = DateTime.parse(params[:start_datetime])
      end_date = DateTime.parse(params[:end_datetime])

      respond_to do |format|
        if @shift.update(start_time: start_date, end_time: end_date)
          format.html do
            redirect_to shifts_admin_shifts_path,
                        notice: "The shift has been successfully updated."
          end
          format.json { render json: { status: "ok" }, status: :ok }
        else
          format.html { render :edit }
          format.json do
            render json: @shift.errors, status: :unprocessable_entity
          end
        end
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json do
          render json: {
                   error: "Missing params"
                 },
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @shift.destroy
    respond_to do |format|
      format.html do
        redirect_to staff_availabilities_path,
                    notice: "The shift has been successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  def update_color
    if params[:user_id].present? &&
         StaffSpace.where(
           user_id: params[:user_id],
           space_id: @user.space_id
         ).present? && params[:color].present?
      staff_space =
        StaffSpace.where(
          user_id: params[:user_id],
          space_id: @user.space_id
        ).first
      if staff_space.update(color: params[:color])
        flash[:notice] = "Color updated successfully"
      else
        flash[:alert] = "Color could not be updated"
      end
    else
      flash[:alert] = "An error occurred, try again later."
    end
    respond_to do |format|
      format.html do
        redirect_to(
          (
            if params[:shifts].present?
              shifts_admin_shifts_path
            else
              admin_shifts_path
            end
          )
        )
      end
      format.json { render json: { status: :ok } }
    end
  end

  def get_availabilities
    opacity = params[:transparent].present? ? 0.25 : 1
    staff_availabilities = []
    @space_id = params[:space_id] if params[:space_id].present?
    StaffAvailability
      .where(user_id: StaffSpace.where(space_id: @space_id).pluck(:user_id))
      .each do |sa|
        event = {}
        event["title"] = "#{sa.user.name} is unavailable"
        event["id"] = sa.id
        event["daysOfWeek"] = [sa.day]
        event["startTime"] = sa.start_time.strftime("%H:%M")
        event["endTime"] = sa.end_time.strftime("%H:%M")
        event["color"] = hex_color_to_rgba(
          sa.user.staff_spaces.find_by(space_id: @space_id).color,
          opacity
        )
        event["userId"] = sa.user.id
        event["className"] = sa.user.name.strip.downcase.gsub(" ", "-")
        staff_availabilities << event
      end

    render json: staff_availabilities
  end

  def get_shifts
    shifts = []

    Shift
      .includes(:users)
      .where(
        "users.id": StaffSpace.where(space_id: @space_id).pluck(:user_id),
        space_id: @space_id
      )
      .each do |shift|
        event = {}
        event["title"] = shift.return_event_title
        event["id"] = shift.id
        event["start"] = shift.start_datetime
        event["end"] = shift.end_datetime
        event["color"] = hex_color_to_rgba(
          shift.color(@space_id),
          shift.pending? ? 0.7 : 1
        )
        event["className"] = "user-#{shift.users.first.id}"
        shifts << event
      end

    render json: shifts
  end

  def get_shift
    shift = Shift.find(params[:id])
    render json: {
             **shift.as_json,
             users: shift.users.map { |u| { id: u.id, name: u.name } }
           }
  end

  def get_staff_needed
    staff_needed = []

    SpaceStaffHour
      .where(space_id: @space_id)
      .each do |shift|
        event = {}
        event["title"] = "Staff Needed"
        event["daysOfWeek"] = [shift.day]
        event["startTime"] = shift.start_time.strftime("%H:%M")
        event["endTime"] = shift.end_time.strftime("%H:%M")
        staff_needed << event
      end

    render json: staff_needed
  end

  def get_external_staff_needed
    render json:
             StaffNeededCalendar.where(space_id: @space_id).as_json(
               only: %i[calendar_url color id]
             )
  end

  def ics
    if params[:staff_needed_calendar_id].present? &&
         StaffNeededCalendar.where(
           id: params[:staff_needed_calendar_id]
         ).present?
      snc = StaffNeededCalendar.find(params[:staff_needed_calendar_id])
      ics_file = URI.open(snc.calendar_url).read
      send_data(ics_file, filename: "snc_#{snc.id}.ics", type: "text/calendar")
    end
  end

  def shift_suggestions
    weekday = params[:day]
    start_time = params[:start]
    end_time = params[:end]
    @suggestions = []
    @excluded = []

    StaffSpace
      .where(space_id: @space_id)
      .each do |staff|
        StaffAvailability
          .where(user_id: staff.user_id)
          .where(day: weekday)
          .each do |availability|
            availability_start_time =
              availability.start_time.strftime("%H%M").to_i
            availability_end_time = availability.end_time.strftime("%H%M").to_i
            shift_start_time = start_time.gsub(":", "").to_i
            shift_end_time = end_time.gsub(":", "").to_i
            if (
                 availability_start_time <= shift_start_time &&
                   availability_end_time <= shift_start_time
               ) ||
                 (
                   availability_start_time >= shift_end_time &&
                     availability_end_time >= shift_end_time
                 )
              unless @suggestions.include?(staff.user) ||
                       @excluded.include?(staff.user)
                @suggestions << staff.user
              end
            else
              @excluded << staff.user unless @excluded.include?(staff.user)
            end
          end
        if StaffAvailability
             .where(user_id: staff.user_id)
             .where(day: weekday)
             .empty?
          @suggestions << staff.user
        end
      end
    render json:
             @suggestions
               .filter { |user| !@excluded.include?(user) }
               .reduce([]) { |arr, user|
                 arr << { id: user.id, name: user.name, acceptable: true }
               } +
               @excluded.reduce([]) { |arr, user|
                 arr << { id: user.id, name: user.name, acceptable: false }
               }
  end

  private

  def set_default_space
    @space_id = @user.space_id || Space.first.id
  end

  def set_shifts
    @shift = Shift.find(params[:id])
  end

  def hex_color_to_rgba(hex, opacity)
    rgb = hex.match(/^#(..)(..)(..)$/).captures.map(&:hex)
    "rgba(#{rgb.join(", ")}, #{opacity})"
  end

  def shift_params
    params.require(:shift).permit(
      :start_datetime,
      :end_datetime,
      :reason,
      :space_id,
      user_id: []
    )
  end
end
