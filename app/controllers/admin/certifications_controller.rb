class Admin::CertificationsController < AdminAreaController
  before_action :set_certification, only: %i[update destroy]

  def update
    past_demotion_reason = @cert.demotion_reason
    if @cert.update(certification_params)
      user = @cert.user
      if @cert.active
        user.flag_message = user.flag_message.gsub("; This user was demoted in '#{@cert.training.name}' because '#{past_demotion_reason}'", '')
        user.flagged = false if user.flag_message.blank?
      else
        user.flag_message += "; This user was demoted in '#{@cert.training.name}' because '#{@cert.demotion_reason}'"
        user.flagged = true
      end
      user.save
      flash[:notice] = 'Action completed.'
    else
      flash[:alert] = 'Something went wrong. Try again later.'
    end
    @cert.active ? redirection = demotions_admin_certifications_path : redirection = user_path(@cert.user.username)
    redirect_to redirection
  end

  def destroy
    if @cert.destroy
      flash[:notice] = "Certification deleted. This action can't be undone"
    else
      flash[:alert] = 'Something went wrong. Try again later.'
    end
    redirect_to demotions_admin_certifications_path
  end

  def open_modal
    @certification_modal = Certification.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def demotions
    @demotions = Certification.inactive
  end

  private

    def certification_params
      params.require(:certification).permit(:active, :demotion_reason)
    end

    def set_certification
      @cert = Certification.unscoped.find(params[:id])
    end
end
