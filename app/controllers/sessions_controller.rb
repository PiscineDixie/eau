#
# Controller pour faire le login/logout des usagers
#
class SessionsController < ApplicationController
  
  # This avoids CSRF checking when posting the auth code
  skip_before_action :verify_authenticity_token, :only => [:create, :reject]
    
  def create
    auth = request.env['omniauth.auth']
    user = User.omniauth(auth)
    provider = params['provider'].split('_')[0]
    if user.nil?
      flash[:notice] = "Accès refusé à #{auth.info.email}."
    else
      session[:user] = user.id
      flash[:notice] = "Accès accordé à #{user.courriel} avec le role #{user.roles}."
    end
    redirect_to root_url
  end

  def reject
    reset_session
    msg = params[:msg]
    flash[:notice] = "Accès refusé: #{msg}"
    redirect_to root_url
  end

  def destroy
    reset_session
    flash[:notice] = "Logout complété."
    redirect_to root_url
  end
  
end