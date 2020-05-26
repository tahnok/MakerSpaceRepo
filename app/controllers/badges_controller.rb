class BadgesController < ApplicationController
  layout 'development_program'
  before_action :only_admin_access, only: [:admin, :certify]

  def index
    begin
      if (@user.admin? || @user.staff?)
        @acclaim_data = Badge.filter_by_attribute(params[:search]).order(user_id: :asc).paginate(:page => params[:page], :per_page => 5).all
      else
        @acclaim_data = @user.badges.paginate(:page => params[:page], :per_page => 20)
      end
    end
  end

  def admin
    @order_items = OrderItem.completed_order.order(status: :asc).includes(:order => :user).joins(:proficient_project).paginate(:page => params[:page], :per_page => 20)
  end

  def certify
    # TODO Repair the flash messages when reloading with rails
    begin
      user = User.find(params['user_id'])
      badge_id = params['badge_id']
      response = Excon.post('https://api.youracclaim.com/v1/organizations/ca99f878-7088-404c-bce6-4e3c6e719bfa/badges',
                            :user => Rails.application.secrets.acclaim_api,
                            :password => '',
                            :headers => {"Content-type" => "application/json"},
                            :query => {:recipient_email => user.email, :badge_template_id => badge_id, :issued_to_first_name => user.name.split(" ", 2)[0], :issued_to_last_name => user.name.split(" ", 2)[1], :issued_at => Time.now}
      )

      if response.status == 422
        flash[:alert] = "An error has occurred when creating the badge, this message might help : " + JSON.parse(response.body)['data']['message']

      elsif response.status == 201
        badge_data = JSON.parse(response.body)['data']
        Badge.create(:username => user.username, :user_id => user.id, :image_url => badge_data['image_url'], :issued_to => badge_data['issued_to'], :description => badge_data['badge_template']['description'], :badge_id => badge_data['id'], :badge_template_id => BadgeTemplate.find_by_badge_id(badge_data['badge_template']['id']).id)
        OrderItem.update(params['order_item_id'], :status => "Awarded")
        flash[:notice] = "The badge has been sent to the user !"

      else
        flash[:alert] = "An error has occurred when creating the badge"
      end

    rescue
      flash[:alert] = "An error has occurred when creating the badge"
    ensure
      @order_items = OrderItem.completed_order.order(status: :asc).includes(:order => :user).joins(:proficient_project)
    end

  end

  def only_admin_access
    unless current_user.admin?
      redirect_to development_programs_path
      flash[:alert] = "Only admin members can access this area."
    end
  end

end
