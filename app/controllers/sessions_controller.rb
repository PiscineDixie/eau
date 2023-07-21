#
# Controller pour faire le login/logout des usagers
#
class SessionsController < ApplicationController
      
  def create
    if id_token = flash[:google_sign_in][:id_token]
      id = GoogleSignIn::Identity.new(id_token)
      user = User.from_courriel(id.email_address)
      if user.nil?
        flash[:notice] = "Accès refusé à #{id.email_address}."
      else
        session[:user] = user.id
        flash[:notice] = "Accès accordé à #{user.courriel} avec le role #{user.roles}."
      end
    elsif error = flash[:google_sign_in][:error]
      flash[:notice] = "Accès refusé par Google: #{error}."
    end
    redirect_to root_url
  end

  def destroy
    reset_session
    flash[:notice] = "Logout complété."
    redirect_to root_url
  end
  
end