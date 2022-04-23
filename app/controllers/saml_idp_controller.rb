# frozen_string_literal: true

require 'digest'

class SamlIdpController < ApplicationController
  include SamlIdp::Controller
  include ApplicationHelper

  protect_from_forgery

  before_action :validate_saml_request, only: %i[login auth]

  layout false # this is technically outside the "standard" website

  def login
    @current_user = current_user if signed_in?

    render template: 'saml/login'
  end

  def metadata
    render xml: SamlIdp.metadata.signed
  end

  def auth
    @current_user = case params[:submit]
                    when 'sign_in'
                      user = sign_in(params[:username], params[:password])

                      @error_message = 'Invalid username/password' if user.nil?

                      user
                    when 'current_user'
                      current_user if signed_in?
                    when 'logout'
                      sign_out
                      nil
                    else
                      @error_message = 'Invalid request'
                      nil
                    end

    if @current_user.nil?
      render template: 'saml/login'
    else
      if @current_user.otp_secret.present?
        redirect_to login_otp_two_factor_auth_index_path(saml: true)
      else
        @saml_response = encode_response @current_user
        render template: 'saml/saml_post'
      end
    end
  end
end
