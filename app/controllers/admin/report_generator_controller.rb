class Admin::ReportGeneratorController < AdminAreaController

  layout 'admin_area'

  def index
  end

  def report1
  	@users = User.all

  	respond_to do |format|
  		attributes = %w{id name username email faculty created_at}
  		format.html
  		format.csv {send_data @users.to_csv(*attributes)}
  	end
  end

  def report2
    @lab_info = LabSession.new
    respond_to do |format|
      format.html
      format.csv {send_data @lab_info.to_csv}
    end
  end

end
