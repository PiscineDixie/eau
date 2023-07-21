
Rails.application.configure do
    config.google_sign_in.client_id     = Rails.application.secrets[:google_sign_in][:client_id]
    config.google_sign_in.client_secret = Rails.application.secrets[:google_sign_in][:client_secret]
end