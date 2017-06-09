class ReportGeneratorController < ApplicationController
  def index
  	@users = User.all

  	respond_to do |format|
  		attributes = %w{id name username email faculty created_at}
  		format.html
  		format.csv {send_data @users.to_csv(*attributes)}
  	end
  end
end
