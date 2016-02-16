# coding: utf-8
class UsersController < ApplicationController
  
  before_action :authenticate
  
  def authenticate
    return true if User.count.zero?
    self.check_admin
  end
  
  # Use the common layout for all controllers
  layout "eau"
  
  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    if (params[:cancel])
      redirect_to(users_url)
      return;
    end
    
    @user = User.new(user_params(params))
  
    if !User.empty? && !validateRole(@user.roles)
      render :action => "new"
      return
    end
    
    if @user.save
      flash[:notice] = 'Nouvel usager créé.'
      redirect_to(@user)
      return
    end
     
    # Les parametres etaient invalides, on recommence
    render :action => "new"
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])

    if (params[:cancel])
      redirect_to(@user)
      return;
    end
    
    if !validateRole(params[:user][:roles])
      render :action => "edit"
      return
    end
    
    if @user.update(user_params(params))
      flash[:notice] = 'Usager modifié.'
      redirect_to(@user)
    else
      render :action => "edit"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    
    # On doit empecher un usager de s'enlever sinon l'authentification ne le retrouve plus
    if @user.id == session[:user]
      flash[:notice] = 'Vous ne pouvez enlever votre usager.'
      redirect_to(users_url)
      return
    end
    
    if validateRole(@user.roles)
      @user.destroy
    end
    redirect_to(users_url)
  end
  
private
  
  # S'assurer que l'usager actif ne modifie pas un compte avec un role superieur au sien
  def validateRole(roleStr)
    if !User.isPeerOrSuperior(session[:user], roleStr)
      flash[:notice] = "Vous n'avez pas le droit de modifier un compte au rôle supérieur."
      return false
    end

    return true
  end

  def user_params(params)
    params.require(:user).permit([:nom, :courriel, :roles])
  end
end
