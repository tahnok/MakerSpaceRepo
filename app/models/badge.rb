class Badge < ActiveRecord::Base
  belongs_to :user
  belongs_to :badge_template

  def self.get_badge_image(badge_id)
    begin
      response = Excon.get('https://api.youracclaim.com/v1/organizations/ca99f878-7088-404c-bce6-4e3c6e719bfa/badge_templates/'+badge_id,
                           :user => Rails.application.secrets.acclaim_api || ENV.fetch("acclaim_api"),
                           :password => '',
                           :headers => {"Content-type" => "application/json"}
      )
      return JSON.parse(response.body)['data']['image_url']
    rescue
      return nil
    end
  end
end
