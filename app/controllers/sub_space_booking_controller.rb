class SubSpaceBookingController < ApplicationController
  before_action :user_account
  before_action :user_signed_in, only: %i[index request_access bookings]
  before_action :user_approved, only: [:create]
  before_action :user_admin_or_staff,
                only: %i[approve decline approve_access deny_access users]
  before_action :user_admin, only: [:publish]
  before_action :user_booking_belongs, only: %i[delete edit update]
  def index
    @subspace = SubSpace.find(params[:room]) if params[:room].present?
    @bookings =
      SubSpaceBooking.where(user_id: current_user.id).order(:start_time)
    if current_user.admin?
      # Need to get the booking status from the sub space booking status table for the booking
      @pending_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::PENDING.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time > Time.now }
          .sort_by { |booking| booking.start_time }
          .paginate(page: params[:pending_page], per_page: 15)
      @approved_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::APPROVED.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time > Time.now }
          .sort_by { |booking| booking.start_time }
          .paginate(page: params[:approved_page], per_page: 15)
      @declined_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::DECLINED.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time > Time.now }
          .sort_by { |booking| booking.start_time }
          .paginate(page: params[:denied_page], per_page: 15)
      @old_pending_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::PENDING.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time < Time.now }
          .sort_by { |booking| booking.start_time }
          .reverse
          .paginate(page: params[:old_pending_page], per_page: 15)
      @old_approved_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::APPROVED.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time < Time.now }
          .sort_by { |booking| booking.start_time }
          .reverse
          .paginate(page: params[:old_approved_page], per_page: 15)
      @old_declined_bookings =
        SubSpaceBookingStatus
          .where(booking_status_id: BookingStatus::DECLINED.id)
          .map { |booking_status| booking_status.sub_space_booking }
          .select { |booking| booking.end_time < Time.now }
          .sort_by { |booking| booking.start_time }
          .reverse
          .paginate(page: params[:old_denied_page], per_page: 15)
    end
  end

  def request_access
    if UserBookingApproval.where(user: current_user).first.nil?
      UserBookingApproval.create(
        user: current_user,
        date: Time.now,
        comments: params[:comments],
        approved: false
      )
      flash[:notice] = "Access request submitted successfully."
    else
      flash[:alert] = "You have already requested access."
    end
    redirect_to root_path
  end

  def approve_access
    if params[:id].nil?
      user = User.find(params[:user_id])
      UserBookingApproval.new(
        user: user,
        date: Time.now,
        approved: true,
        staff: current_user
      ).save
      user.update(booking_approval: true)
      user.save!
      redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab")
    else
      user = UserBookingApproval.find(params[:id]).user
      UserBookingApproval.find(params[:id]).update(approved: true)
      UserBookingApproval.find(params[:id]).update(staff_id: current_user.id)
      user.booking_approval = true
      user.save!
      redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab"),
                  notice: "Access request approved successfully."
    end
  end

  def deny_access
    user = UserBookingApproval.find(params[:id]).user
    UserBookingApproval.find(params[:id]).destroy
    user.booking_approval = false
    user.save!
    redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab"),
                notice: "Access request declined successfully."
  end

  def users
    render json: User.all
  end

  def bookings
    @bookings = []
    if params[:room].present?
      SubSpaceBooking
        .where(sub_space_id: params[:room])
        .each do |booking|
          booking_status =
            SubSpaceBookingStatus.find(booking.sub_space_booking_status_id)
          if booking_status.booking_status_id == BookingStatus::APPROVED.id ||
               booking_status.booking_status_id == BookingStatus::PENDING.id
            color = booking.user == current_user ? "#49794b" : "#497979"
            if booking_status.booking_status_id == BookingStatus::PENDING.id
              color = booking.user == current_user ? "#B5A500" : "#FFA500"
            end
            if booking.blocking
              color = "#ABABABFF"
              title = "Space Blocked" if (
                !booking.public &&
                  ((!current_user.admin?) || booking.user != current_user)
              )
            end
            title = "#{booking.name} - #{booking.description}"
            title =
              (
                current_user.admin? || booking.user == current_user ||
                  booking.public
              ) ?
                title :
                booking.public ? title : "Space Booked"
            title =
              (
                if booking_status.booking_status_id == BookingStatus::PENDING.id
                  title + " (Pending)"
                else
                  title
                end
              )
            title += " - #{booking.user.name}" if current_user.admin? &&
              booking.user != current_user
            event = {
              id:
                "booking_" + booking.id.to_s + "_" + booking.sub_space_id.to_s,
              title: title,
              start: booking.start_time,
              end: booking.end_time,
              color: color
            }
            @bookings << event
          end
        end
    end
    render json: @bookings
  end

  def create
    booking = SubSpaceBooking.new(sub_space_booking_params)
    unless booking.valid?
      render json: {
               errors: booking.errors.full_messages
             },
             status: :unprocessable_entity
      return
    end
    if params[:sub_space_booking][:blocking] && !current_user.admin?
      flash[:alert] = "You do not have permission to block a space."
      redirect_to sub_space_booking_index_path
    end
    if params[:sub_space_booking][:recurring].present?
      if params[:sub_space_booking][:recurring] == true
        if params[:sub_space_booking][:recurring_end].present? &&
             params[:sub_space_booking][:recurring_frequency].present?
          params[:sub_space_booking][:recurring_frequency] == "weekly" ?
            recurrence = 7.days :
            recurrence = 1.month
          epoch_start = params[:sub_space_booking][:start_time].to_datetime
          start_time = params[:sub_space_booking][:start_time].to_datetime
          end_time = params[:sub_space_booking][:end_time].to_datetime
          end_date = params[:sub_space_booking][:recurring_end].to_date
          book(params)
          corrected = false
          while start_time < end_date
            params[:sub_space_booking][:start_time] = start_time + recurrence
            params[:sub_space_booking][:end_time] = end_time + recurrence
            if params[:sub_space_booking][:start_time].in_time_zone.dst? !=
                 epoch_start.in_time_zone.dst? && !corrected
              params[:sub_space_booking][:start_time] += (
                if params[:sub_space_booking][:start_time].in_time_zone.dst?
                  -1.hour
                else
                  1.hour
                end
              )
              params[:sub_space_booking][:end_time] += (
                if params[:sub_space_booking][:end_time].in_time_zone.dst?
                  -1.hour
                else
                  1.hour
                end
              )
              corrected = true
            elsif corrected &&
                  params[:sub_space_booking][:start_time].in_time_zone.dst? ==
                    epoch_start.in_time_zone.dst?
              corrected = false
            end
            start_time = params[:sub_space_booking][:start_time].to_datetime
            end_time = params[:sub_space_booking][:end_time].to_datetime
            book(params)
          end
        end
      end
    else
      book(params)
    end
  end

  def book(params)
    booking = SubSpaceBooking.new(sub_space_booking_params)
    booking.sub_space = SubSpace.find(params[:sub_space_booking][:sub_space_id])
    booking.user_id = current_user.id
    unless booking.save
      render json: {
               errors: booking.errors.full_messages
             },
             status: :unprocessable_entity
      return
    end
    if params[:sub_space_booking][:blocking] != "true" &&
         SubSpaceBooking
           .where(sub_space_id: params[:sub_space_booking][:sub_space_id])
           .where(blocking: true)
           .where.not(id: booking.id)
           .where(
             "(start_time, end_time) OVERLAPS (?,?)",
             params[:sub_space_booking][:start_time].to_datetime,
             params[:sub_space_booking][:end_time].to_datetime
           )
           .any?
      booking.destroy
      respond_to do |format|
        format.json do
          render json: {
                   errors: ["TimeSlot This time slot is already booked."]
                 },
                 status: :unprocessable_entity
        end
        format.html do
          flash[:alert] = "This time slot is already booked."
          redirect_to sub_space_booking_index_path(
                        anchor: "booking-calendar-tab",
                        room: params[:sub_space_booking][:sub_space_id]
                      )
        end
      end
      return
    end

    # Check time violations
    duration = (booking.end_time - booking.start_time) / 1.hour
    if !SubSpace
         .find(params[:sub_space_booking][:sub_space_id])
         .maximum_booking_duration
         .nil? && !current_user.admin?
      if duration > booking.sub_space.maximum_booking_duration
        render json: {
                 errors: [
                   "DurationHour You cannot book #{booking.sub_space.name} for more than #{booking.sub_space.maximum_booking_duration} hours."
                 ]
               },
               status: :unprocessable_entity
        booking.destroy
        return
      end
    end

    if !SubSpace
         .find(params[:sub_space_booking][:sub_space_id])
         .maximum_booking_hours_per_week
         .nil? && !current_user.admin?
      user_bookings =
        SubSpaceBooking
          .where(sub_space_id: booking.sub_space.id)
          .where(user_id: current_user.id)
          .where("start_time >= ?", DateTime.now.beginning_of_week)
          .where("start_time <= ?", DateTime.now.end_of_week)
      total_duration = 0 - duration
      user_bookings.each do |booking|
        total_duration += booking.end_time - booking.start_time
      end
      total_duration = total_duration / 1.hour
      if total_duration > booking.sub_space.maximum_booking_hours_per_week
        render json: {
                 errors: [
                   "DurationWeek You cannot book #{booking.sub_space.name} for more than #{booking.sub_space.maximum_booking_hours_per_week} hours per week."
                 ]
               },
               status: :unprocessable_entity
        booking.destroy
        return
      end
    end

    status =
      SubSpaceBookingStatus.new(
        sub_space_booking_id: booking.id,
        booking_status_id:
          (
            if SubSpace.find(
                 params[:sub_space_booking][:sub_space_id]
               ).approval_required
              if SubSpace
                   .find(params[:sub_space_booking][:sub_space_id])
                   .max_automatic_approval_hour
                   .nil?
                BookingStatus::PENDING.id
              elsif duration <=
                    SubSpace.find(
                      params[:sub_space_booking][:sub_space_id]
                    ).max_automatic_approval_hour
                BookingStatus::APPROVED.id
              elsif duration >
                    SubSpace.find(
                      params[:sub_space_booking][:sub_space_id]
                    ).max_automatic_approval_hour
                BookingStatus::PENDING.id
              end
            else
              BookingStatus::APPROVED.id
            end
          )
      )
    status.save
    booking.sub_space_booking_status_id = status.id
    booking.public =
      SubSpace.find(params[:sub_space_booking][:sub_space_id]).default_public
    booking.save
    flash[
      :notice
    ] = "Booking for #{booking.sub_space.name} created successfully."
    if booking.sub_space.approval_required &&
         booking.sub_space_booking_status.booking_status_id ==
           BookingStatus::PENDING.id
      BookingMailer.send_booking_needs_approval(booking.id).deliver_now
    end
  end
  def edit
    @sub_space_booking = SubSpaceBooking.find(params[:sub_space_booking_id])
  end

  def update
    @sub_space_booking = SubSpaceBooking.find(params[:sub_space_booking_id])
    if @sub_space_booking.update(sub_space_booking_params)
      redirect_to sub_space_booking_index_path(
                    anchor: "booking-calendar-tab",
                    room: @sub_space_booking.sub_space_id
                  )
    else
      render "edit"
    end
  end

  def approve
    booking =
      SubSpaceBookingStatus.find(
        SubSpaceBooking.find(
          params[:sub_space_booking_id]
        ).sub_space_booking_status_id
      )
    booking.booking_status_id = BookingStatus::APPROVED.id
    booking.save

    redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab"),
                notice:
                  "Booking for #{SubSpaceBooking.find(params[:sub_space_booking_id]).sub_space.name} approved successfully."
    BookingMailer.send_booking_approved(
      params[:sub_space_booking_id]
    ).deliver_now
  end

  def decline
    booking =
      SubSpaceBookingStatus.find(
        SubSpaceBooking.find(
          params[:sub_space_booking_id]
        ).sub_space_booking_status_id
      )
    booking.booking_status_id = BookingStatus::DECLINED.id
    booking.save
    redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab"),
                notice:
                  "Booking for #{SubSpaceBooking.find(params[:sub_space_booking_id]).sub_space.name} declined successfully."
  end

  def publish
    booking = SubSpaceBooking.find(params[:sub_space_booking_id])
    booking.public = !booking.public
    booking.save
    redirect_to sub_space_booking_index_path(anchor: "booking-admin-tab"),
                notice:
                  "Booking made #{booking.public ? "public" : "private"} successfully."
  end

  def delete
    unless current_user.admin? ||
             SubSpaceBooking.find(params[:sub_space_booking_id]).user_id ==
               current_user.id
      return(
        redirect_to root_path,
                    alert: "You are not authorized to view this page."
      )
    end
    booking = SubSpaceBooking.find(params[:sub_space_booking_id])
    subspaceName = booking.sub_space.name
    status = SubSpaceBookingStatus.find(booking.sub_space_booking_status_id)
    status.sub_space_booking_id = nil
    status.save
    booking.sub_space_booking_status_id = nil
    booking.save
    status.destroy
    booking.destroy
    redirect_to sub_space_booking_index_path(anchor: "booking-tab"),
                notice: "Booking for #{subspaceName} deleted successfully."
  end

  private

  def user_account
    unless !current_user.nil?
      redirect_to login_path, alert: "You must be logged in to view this page."
    end
  end
  def user_signed_in
    unless signed_in?
      redirect_to login_path, alert: "You must be logged in to view this page."
      return
    end
  end
  def user_approved
    unless current_user.booking_approval || current_user.admin?
      redirect_to root_path,
                  alert: "You must be approved to book to view this page."
    end
  end
  def user_admin_or_staff
    unless current_user.admin? || current_user.staff?
      redirect_to root_path,
                  alert: "You must be an admin or staff to view this page."
    end
  end
  def user_admin
    unless current_user.admin?
      redirect_to root_path, alert: "You must be an admin to view this page."
    end
  end
  def user_booking_belongs
    unless SubSpaceBooking.find(params[:sub_space_booking_id]).user_id ==
             current_user.id || current_user.admin?
      redirect_to root_path,
                  alert:
                    "You must be the owner of this booking or an admin to delete it."
    end
  end

  def sub_space_booking_params
    params.require(:sub_space_booking).permit(
      :start_time,
      :end_time,
      :name,
      :description,
      :sub_space_id,
      :blocking
    )
  end
end
