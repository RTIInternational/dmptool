# frozen_string_literal: true

module Users
  # Overrides to Devise Omniauth controller
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
    skip_before_action :verify_authenticity_token, only: %i[orcid shibboleth]

    def failure

p "FAIL: #{failed_strategy.name}"

      Rails.logger.error "OmniauthCallbacksController - FAILURE for #{failed_strategy.name}"
      super
    end

    # GET|POST /users/auth/shibboleth/callback
    def shibboleth
      omniauth = omniauth_from_request

pp request.headers

pp omniauth

      scheme_name = 'shibboleth'
      user = User.from_omniauth(scheme_name: scheme_name, omniauth_hash: omniauth)
      process_omniauth_response(scheme_name: scheme_name, user: user, omniauth_hash: omniauth)
    end

    # GET|POST /users/auth/orcid/callback
    def orcid
      omniauth = omniauth_from_request
      scheme_name = 'orcid'
      user = User.from_omniauth(scheme_name: scheme_name, omniauth_hash: omniauth)
      process_omniauth_response(scheme_name: scheme_name, user: user, omniauth_hash: omniauth)
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def process_omniauth_response(scheme_name:, user:, omniauth_hash:)
      msg = _('Unable to process your request')
      redirect_to(:back, alert: msg) and return unless user.present? &&
                                                       omniauth_hash.present? &&
                                                       scheme_name.present?

      # If the user is already signed in add the OmniAuth provided UID
      if current_user.present? && omniauth_hash[:uid].present?
        handle_third_party_app_registration(
          user: current_user, scheme_name: scheme_name, omniauth_hash: omniauth_hash
        )

      elsif user.persisted?
        # We found the user by the OmniAuth UID so sign them in
        flash[:notice] = _('Successfully signed in')
        sign_in_and_redirect user, event: :authentication

      else
        handle_new_user_sign_in(
          user: user, scheme_name: scheme_name, omniauth_hash: omniauth_hash
        )
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # The path used when OmniAuth fails
    def after_omniauth_failure_path_for(_scope)
      #   super(scope)
      redirect_to root_path, alert: _('We are having trouble communicating with your institution at this time.')
    end

    # Attach the UID to their record and return to the third party apps page
    def handle_third_party_app_registration(user:, scheme_name:, omniauth_hash:)
      id = user.attach_omniauth_credentials(
        scheme_name: scheme_name, omniauth_hash: omniauth_hash
      )

      msg = _('Unable to link your account to %<scheme>s')
      msg = _('Your account has been successfully linked to %<scheme>s.') if id.present?

      redirect_to users_third_party_apps_path,
                  alert: format(msg, scheme: provider(scheme_name: scheme_name))
    end

    # New user sign in via Omniauth
    def handle_new_user_sign_in(user:, scheme_name:, omniauth_hash:)
      # Try to find a matching user by the email address provided by OmniAuth
      existing = User.where_case_insensitive('email', user.email).first

      if existing.present?
        # If we found a matching email address then attach the UID to that record
        # and sign them in
        existing.attach_omniauth_credentials(
          scheme_name: scheme_name, omniauth_hash: omniauth_hash
        )
        flash[:notice] = _('Successfully signed in')
        sign_in_and_redirect existing, event: :authentication

      else
        # If we could not find a match then take them to the account setup page to give
        # them an opportunity to sign in with a password (scenarios where the user had
        # an account before their Org was setup for SSO) or correct any of the info we
        # got from OmniAuth (e.g. First name, Last name)
        redirect_to_registration(scheme_name: scheme_name, omniauth_hash: omniauth_hash)
      end
    end

    # rubocop:disable Layout/LineLength
    def redirect_to_registration(scheme_name:, omniauth_hash:)
      session["devise.#{scheme_name.downcase}_data"] = omniauth_hash
      redirect_to new_user_registration_path,
                  notice: _('It looks like this is your first time signing in. Please verify and complete the information below to finish creating an account.')
    end
    # rubocop:enable Layout/LineLength

    # Sign up a user and tries to redirect first to the stored location and
    # then to the url specified by after_sign_in_path_for. It accepts the same
    # parameters as the sign_in method.
    def sign_up_and_redirect(resource_or_scope, *args)
      options  = args.extract_options!
      scope    = Devise::Mapping.find_scope!(resource_or_scope)
      resource = args.last || resource_or_scope
      sign_in(scope, resource, options)
      redirect_to after_sign_up_path_for(resource)
    end

    # Return the visual name of the scheme
    def provider(scheme_name:)
      scheme = IdentifierScheme.find_by(name: scheme_name.downcase)
      return _('your institutional credentials') if scheme&.name == 'shibboleth'

      scheme&.description
    end

    # Extract the omniauth info from the request
    def omniauth_from_request
      return {} unless request.env.present?

      omniauth_hash = request.env['omniauth.auth']
      omniauth_hash.present? ? omniauth_hash.to_h : {}
    end
  end
end
