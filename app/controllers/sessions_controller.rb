#
# Controller pour faire le login/logout des usagers
#
class SessionsController < ApplicationController
  def create
    auth = env['omniauth.auth']
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