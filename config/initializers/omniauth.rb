#
# Initialize omniauth with our social login credentials
#
OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, 
    Rails.application.secrets[:social][:facebook][:app],
    Rails.application.secrets[:social][:facebook][:secret]
    
  provider :google_oauth2, 
    Rails.application.secrets[:social][:google][:app],
    Rails.application.secrets[:social][:google][:secret],
    {
      provider_ignores_state: true
    }
end
