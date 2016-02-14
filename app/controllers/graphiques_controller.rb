# coding: utf-8
#
# Controlleur pour generer les graphiques
# Il n'y a pas d'edit puisque les graphiques sont generes a partir des donnees
# de Journee et Mesure
#

class GraphiquesController < ApplicationController

  before_action :authenticate
  
  # Use the common layout for all controllers
  layout "eau"
  
  # Rediriger a la selection du graphique
  def index
    redirect_to(:action => :select)  
  end
  
  # Choisir le graphiques desire ainsi que la periode
  def select
    # Si le retour du formulaire, faire la requete "show" appropriee
    if request.post?
      fin = readDate(params['fin']) if params['fin']
      depart = readDate(params['depart']) if params['depart']
      dateRange = depart.to_s(:db)+':'+fin.to_s(:db)
      redirect_to("/graphiques/show/#{params['indic']}/#{dateRange}")
    else
      # Sinon afficher le formulaire pour choisir le graphique
      # Les defaults pour la date
      @fin = Date.today
      @depart = @fin - 14
    end
  end

  # GET /graphiques/show/indicateur/<date range>
  #  - indicateur peut etre "all" pour afficher tous les graphiques
  #  <date range> est exprime selon le format: <date1>-<date2>   20080112-200801-20
  # Si la date2 est omise, on assume 2 semaines de moins que la date1
  # Les dates peuvent aussi etre disponible dans les attributs "depart[year,month,day]"
  # et "fin[year,month,day".
  def show
    # Les valeurs par defaut
    indic = params[:type]
    @fin=nil
    @depart=nil
    @graphs=Array.new
    
    # REST routing.
    # Valider le type de requete
    if (indic != 'toutes' and not Mesure::Indicateurs.include?(indic))
      logger.info("Invalid request in show graphique")
      flash[:notice] = "Requete pour un graphique inexistant: ", indic
      redirect_to(:action => :select)
      return
    end
      
    # Determiner la periode specifiee
    unless params[:dateRange].nil?
      strs = params[:dateRange].split(':')
      if strs.size() == 1
        @fin = strs[0].to_time.to_date
        @depart = @fin - 14 unless @fin.nil?
      else
        @fin = strs[1].to_time.to_date
        @depart = strs[0].to_time.to_date
      end
    else
      @fin = Date.today;
      @depart = @fin - 14
    end
    
    # Valider cette periode
    if @fin.nil? or @depart.nil?
      logger.info("Invalid period request in show graphique")
      flash[:notice] = "Requete pour un graphique inexistant d'une periode invalide:", :dateRange
      redirect_to(:action => :select)
      return
    end
      
    logger.info(["Generer un graphique pour", @depart, @fin])
    
    # Determiner les graphiques a afficher
    indic == "toutes" ? indics = Mesure::Indicateurs : indics = [indic]
      
    indics.each do | i |
      g = Graphique.new(i, @depart, @fin)
      @graphs << [i, g.toGoogleChart] if g.valid?
    end
    
    if @graphs.empty?
      flash[:notice] = "Aucun graphique disponible pour cette periode."
      redirect_to(:action => :select)
      return
    end
  end
  
  private
  
  # Utilitaire pour recuperer une date d'un hash de params
  def readDate(var)
    return Date.new(var[:year].to_i,var[:month].to_i, var[:day].to_i)
  end
end
