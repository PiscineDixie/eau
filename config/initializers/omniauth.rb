#
# Initialize omniauth with our social login credentials
#
OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # prod account
  provider :facebook, 
    "377502229121424", 
    "ec2403a86e2161a2ef077cd555e37a6e"
    
  # provider :facebook, "1548975615363971", "62f3c774006ad004c015b2b35bcc47dd"  # dev account
  
  # Google: works for both prod and dev
  provider :google_oauth2, 
    '1040962372599-s1m9rrdlgdo6bk12u4sjcuq877hvtvk6.apps.googleusercontent.com',
    'ricli_IzGIbA10YvGasn63zz', {
      provider_ignores_state: true
    }
end