# frozen_string_literal: true

class SettingsController < SessionsController

  before_action :current_user
  before_action :signed_in

  layout 'setting'

  def profile
    @programs = ProgramList.fetch_all
    if current_user.program.present?
      @user_program = current_user.program.gsub("\n", '')
      @user_program = @user_program.gsub("\r", '')
    else
      @user_program = ''
    end
  end

  def admin
    if github?
      @client = github_client
      @client_info = @client.user
    end

    unless @user.otp_secret.present?
      @otp_secret = ROTP::Base32.random
      totp = ROTP::TOTP.new(
        @otp_secret, issuer: 'MakerRepo'
      )
      @qr_code = RQRCode::QRCode
                   .new(totp.provisioning_uri(@user.email))
                   .as_png(resize_exactly_to: 200)
                   .to_data_url    end
  end
end
