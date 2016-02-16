# coding: utf-8
class JourneesController < ApplicationController
  
  before_action :authenticate, except: :destroy
  before_action :check_admin, only: :destroy
    
  # Use the common layout for all controllers
  layout "eau"
  
  # GET /journees
  # GET /journees.xml
  def index
    groups = Journee.all.order(:date).group_by { |j| j.date.to_s(:db)[0,7] }
    @monthly_groups = groups.to_a.sort.reverse
  end

  # GET /journees/1
  # GET /journees/1.xml
  def show
    @journee = Journee.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @journee }
    end
  end

  # GET /journees/new
  # GET /journees/new.xml
  def new
    # Find the days this month which are not filled yet
    jourVides, @jourCompletes = Journee.journeesInfo
    logger.debug("Jours non fait: #{jourVides.to_s}")
    if jourVides.empty?
      flash[:notice] = "Toutes les journées de ce mois sont déja complétées."
      redirect_to(:action => :index)
    else
      @journee = Journee.new
      @journee.date = jourVides[0]
      @journee.fill
    end
  end

  # GET /journees/1/edit
  def edit
    @journee = Journee.find(params[:id])
    @journee.fill
  end

  # POST /journees
  # POST /journees.xml
  def create
    if (params[:cancel])
      redirect_to(journees_url)
      return;
    end
    
    @journee = Journee.new(journee_params(params))
    ok = @journee.mesuresFromForm(params, session[:user])

    respond_to do |format|
      if ok and @journee.save
        if @journee.flash_msg.nil?
          flash[:notice] = 'Données enregistrées pour une nouvelle journée.'
        else
          flash[:notice] = @journee.flash_msg;
        end
        format.html { redirect_to(@journee) }
        format.xml  { render :xml => @journee, :status => :created, :location => @journee }
      else
        @journee.fill
        format.html { render :action => "new" }
        format.xml  { render :xml => @journee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /journees/1
  def update
    @journee = Journee.find(params[:id])
    if (params[:cancel])
      redirect_to(@journee);
      return;
    end
    
    if @journee.mesuresFromForm(params, session[:user]) and @journee.save
      if @journee.flash_msg.nil?
        flash[:notice] = 'Données mises à jour pour la journée.'
      else
        flash[:notice] = @journee.flash_msg;
      end
      redirect_to(@journee)
    else
      @journee.fill
      render :action => "edit"
    end
  end

  # DELETE /journees/1
  # DELETE /journees/1.xml
  def destroy
    @journee = Journee.find(params[:id])
    @journee.destroy

    respond_to do |format|
      format.html { redirect_to(journees_url) }
      format.xml  { head :ok }
    end
  end
  

  # Afficher le registre pour l'annee donnee. Elle est dans params[:annee]
  def registre
    @registre = Registre.new(params[:annee])
    render(:layout => 'plain')
  end

  private
  
  def journee_params(p)
    return p[:journee].permit!
  end
end
