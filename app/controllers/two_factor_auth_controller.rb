class TwoFactorAuthController < ApplicationController

  before_action :signed_in, except: [:login_otp, :verify_otp]
  before_action :check_otp_code, only: [:login_otp, :verify_otp]

  def login_otp; end

  def verify_otp
    last_otp_at = validate_otp(@user.otp_secret)
    if last_otp_at
      @user.update(last_otp_at: last_otp_at)
      session[:user_id] = @user.id
      session[:two_factor_unverified] = nil
      flash[:notice] = 'Successfully signed-in with your Two-Factor Authentication Code!'
    else
      flash[:alert] = 'Invalid Two-Factor Authentication Code'
    end
    redirect_to root_path
  end

  def create
    last_otp_at = validate_otp(params[:otp_secret].to_s)

    if last_otp_at
      @user.update(
        otp_secret: params[:otp_secret].to_s, last_otp_at: last_otp_at
      )
      redirect_to(
        root_path,
        notice: 'Successfully activated Two Factor Authentication for your MakerRepo account!'
      )
    else
      flash[:alert] = 'The code you provided was invalid! Please try again.'
      redirect_to settings_admin_path
    end
  end

  def deactivate
    if validate_otp(@user.otp_secret)
      @user.update!(otp_secret: nil, last_otp_at: nil)
      flash[:notice] = 'Successfully deactivated Two Factor Authentication for your MakerRepo account!'
    else
      flash[:alert] = 'The code you provided was invalid! Please try again.'
    end
    redirect_to settings_admin_path
  end

  private

  def check_otp_code
    unless session[:two_factor_unverified].present?
      redirect_to login_path, alert: 'You need to login first before being able to enter the two factor authentication code.'
    end

    unless User.where(id: session[:two_factor_unverified]).present?
      redirect_to login_path, alert: 'The user you are trying to login with does not exist.'
    end

    @user = User.find(session[:two_factor_unverified])
  end

  def validate_otp(otp_secret)
    totp = ROTP::TOTP.new(
      otp_secret, issuer: 'MakerRepo'
    )

    totp.verify(
      params[:otp_attempt].to_s, drift_behind: 15
    )
  end

end
