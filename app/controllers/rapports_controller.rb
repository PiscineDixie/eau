# coding: utf-8
# Classe pour preparer une demande de rapports
#
class RapportsController < ApplicationController

  # Use the common layout for all controllers
  layout "eau"
  
  before_action :authenticate

  # Calcul de la conformite pour un indicateur
  def conformite
    if request.post?
      fin = readDate(params['fin']) if params['fin']
      depart = readDate(params['depart']) if params['depart']
      @dateRange = depart.to_s(:db)+':'+fin.to_s(:db)
      @indic = params[:indic]
      
      # Obtenir les mesures pour cette plage de la db
      mesures = Mesure.
        joins('as m inner join journees as j on m.journee_id = j.id').
        where("indicateur = :indic and date >= :minDate and date <= :endDate", 
          {:indic => @indic, :minDate => depart.to_s(:db), :endDate => fin.to_s(:db)}).
        select('date, temps, valeur').to_a
        
      # Ordonner par par heure d'entree
      mesures.sort! { |x,y| x.temps <=> y.temps }
      
      # Calculer le nombre de minutes total et le nombre de minutes sous la norme
      gi = Mesure::IndicateursGraphData.assoc(@indic)
      @minV = 0
      @maxV = 0
      if (gi.size == 3)
        @maxV = gi[2];
      else
        @maxV = gi[3]
        @minV = gi[2];
      end
      
      @nonConf = []
      @totTime = 0
      @totBadTime = 0
      (0...mesures.size-1).each do | mIdx |
        curr = mesures[mIdx]
        proch = mesures[mIdx + 1]
        currDate = curr.temps.localtime.to_date
        prochDate = proch.temps.localtime.to_date
        next if currDate != prochDate
        intvl = proch.temps.to_i - curr.temps.to_i
        @totTime += intvl
        if curr.valeur > @maxV or curr.valeur < @minV
          @nonConf << [curr.temps, proch.temps, curr.valeur]
          @totBadTime += intvl
        end
      end
      
      # continuer pour afficher la vue
      
    else
      redirect_to(:index);
    end
  
  end


  # Utilitaire pour recuperer une date d'un hash de params
  def readDate(var)
    return Date.parse(var)
  end

end
