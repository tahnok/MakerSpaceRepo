class AnnouncementsController < ApplicationController
  layout 'volunteer'
  def new
    @announcement = Announcement.new
  end

  def create
    announcement = Announcement.new(announcement_params)
    announcement.user_id = current_user.id
    if announcement.save!
      redirect_to announcements_path
      flash[:notice] = "You've successfully created an announcement for #{announcement.public_goal.capitalize}"
    end

  end

  def update
    announcement = VolunteerTask.find(params[:id])
    if announcement.update(announcement_params)
      flash[:notice] = "Announcement updated"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to announcements_path
  end

  def destroy

  end

  private

  def announcement_params
    params.require(:announcement).permit(:description, :public_goal, :active)
  end
end
