class HelpController < SessionsController
  skip_before_action :session_expiry
  before_action :current_user

  layout 'help'

  def main; end

  def send_email
    if verify_recaptcha || params[:app_version].present?
      @name = params[:name]
      @email = params[:email]
      @subject = params[:subject]
      @comments = params[:comments]
      @app_version = params[:app_version]
      MsrMailer.issue_email(@name, @email, @subject, @comments, @app_version).deliver_now
      respond_to do |format|
        format.html {
          redirect_to help_path, notice: 'Email successfully sent. You will be contacted soon.'
        }
        format.json {
          render json: {
            status: 'success'
          }
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to help_path, alert: 'Please make sure you fill out the captcha correctly.'
        }
        format.json {
          render json: {
            status: 'error'
          }
        }
      end
    end
  end
end
