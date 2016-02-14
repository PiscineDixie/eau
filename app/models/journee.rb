# coding: utf-8
#
# Cette classe represente une journee. Elle contient plusieurs mesures
class Journee < ActiveRecord::Base
  
  attr_accessor :flash_msg
  
  has_many :mesures, :dependent => :delete_all, :autosave => true
  
  # Un seul champ:
  #  date - date de la collecte
  #
  validates_presence_of :date
  validates_associated :mesures

  # Methode pour ajouter automatiquement des mesures a la journee
  def fill
    # Obtenir la list des indicateurs de base et les ajouter une seule fois avec
    # la valeur de mi-journee.
    indics = Mesure::Indicateurs.clone - Mesure::Indicateurs3X - Mesure::IndicateursH
    indics.each { |indic | addFixedIndic(indic, ['12:00']) }
    
    # Ajouter les indicateurs 3x par jours
    Mesure::Indicateurs3X.each { |indic| addFixedIndic(indic, ['8:00', '12:00', '20:00']) }
    
    # Ajouter les indicateurs pris au debut et a la fin de la journee et a certaines heures
    # Permettre jusqu'a 6 heures differentes
    Mesure::IndicateursH.each do |indic|
      if indic != 'Chloramines'
        addVariableIndic(indic, ['8:00']+Mesure::Heures, 5)
        addFixedIndic(indic, ['20:00'])
      end
    end
  end
  
  # Ajouter une valeur pour chaque periode donnee
  def addFixedIndic(indic, heures)
    # Convertir les heures en time
    trgtTimes = heures.each.map() { |h| Time.parse(h).utc }
    trgtTimes.each do | t |
      m = self.mesures.find_by_indicateur_and_temps(indic, t.utc)
      if m.nil?
        self.mesures << Mesure.new( :indicateur => indic, :temps => t)
      end
    end
  end
  
  # S'assurer qu'il y a au moins "maxVar" entrees parmis "heures" pour
  # l'indicateur donne
  def addVariableIndic(indic, heures, maxVar)
    # Convertir les heures en time
    trgtTimes = heures.each.map() { |h| Time.parse(h) }
      
    # Trouver les heures deja presentes
    mesuresIndic = self.mesures.where(indicateur: indic)
    maxVar = maxVar - mesuresIndic.length
    mesuresIndic.each do |m|
      trgtTimes.delete(m.temps)
    end
    
    # Ajouter le nombre d'heures manquantes
    if maxVar > 0
      gap = trgtTimes.size / maxVar
      0.upto(maxVar-1) do |i|
        self.mesures << Mesure.new(:indicateur => indic, :temps => trgtTimes[i*gap + 1])
      end
    end
  end

  # Enlever les mesures non utilisees
  def deleteIfBlank
    self.mesures.each do |m|
      if m.valeur.nil?
        m.destroy
      end
    end
  end
  
  # Ordonnee les mesures pour afficher correctement
  # Ceci est necessaire lorsqu'on recharche une journee deja cree.
  # Depend de la methode <=> de Mesure
  def mesuresSorted
    self.mesures.to_a.sort
  end
  
  # Lire les mesures a partir du contenu de notre page web
  # Chacune des mesure a une clef avec le pattern mesure_indicateur_idx_{heure,valeur}
  def mesuresFromForm(params, userId)
    # Eliminer tout sauf les mesures de l'input. Ordonner en paires (heure, valeur)
    parms = params.sort
    parms.delete_if { |x| x[0].match(/^mesure:/).nil?  }
    locTime = Time.local(self.date.year, self.date.month, self.date.mday)
    outOfBound = []
    0.step(parms.size()-2, 2) do |idx|
      raise ArgumentError, "Unexpected input #{parms[idx]} #{parms[idx+1]}" unless parms[idx][0] =~ /heure$/ && parms[idx+1][0] =~ /valeur$/
      fieldVal = parms[idx+1][1]
      if not fieldVal.blank?
        # Valeur specifiee par l'usager. Creer l'objet Mesure correspondant.
        fieldHeure = parms[idx][1]
        temps = Time.parse(fieldHeure, locTime)
        indic = parms[idx][0].split(':')[1]
        
        # Verifier si cette mesure existe deja
        m = self.mesures.find_by_indicateur_and_temps(indic, temps)
        unless m.nil?
          m.valeur = fieldVal
          return false unless m.valid?
          m.save!
        else
          m = Mesure.new(:indicateur => indic, :temps => temps, :valeur => fieldVal, :user_id => userId)
          return false unless m.valid?
          self.mesures << m
        end
        outOfBound << m unless m.inRange?
      end
    end
    
    calculeChloramines(outOfBound, userId)
    
    @flash_msg = nil
    unless outOfBound.empty?
      @flash_msg = "ATTENTION: Valeur(s) hors normes: "
      outOfBound.each do | m |
        @flash_msg << "#{m.indicateur} à #{m.to_heure_s}, "
      end
    end
    
    return true
  end
  
  # Calcule de la valeur des chloramines. Obtenue par chlore total - chlore residuel
  def calculeChloramines(outOfBound, userId)
    # Aller chercher les records pour le desinfectant total
    return if self.mesures.nil?
    self.mesures.each do | tot |
      if tot['indicateur'] == 'Désinfectant_total'
        chloramineIdx = self.mesures.index { | m | m['indicateur'] == 'Chloramines' and m.temps == tot.temps }
        if chloramineIdx.nil?
          libreIdx = self.mesures.index { | m | m['indicateur'] == 'Désinfectant_résiduel' and m.temps == tot.temps }
          if !libreIdx.nil?
            libre = self.mesures[libreIdx]
            m = Mesure.new(:indicateur => 'Chloramines', :temps => tot.temps, :valeur => tot.valeur - libre.valeur, :user_id => userId)
            mesures << m
            outOfBound << m unless m.inRange?
          end
        end
      end
    end
  end
  
  # Les auteurs de toutes les mesures de la journee
  def auteurs
    # Trouver tous les uids
    uids = {}
    self.mesures.each do | m |
      uids[m.user_id] = nil unless m.user_id.zero? || uids.has_key?(m.user_id)
    end
    # Faire une requete dans la db pour ces uids
    users = User.select('nom').where(:id => uids.keys)
    noms = []
    users.each { |u| noms << u.nom }
    return noms.join(',')
  end
  
  # Retourner deux valeurs avec:
  #  0 - les journées du mois courant pour lesquelles nous n'avons pas de données.
  #  1 - les journess du mois courant pour lesquelles nous avons des données.
  def self.journeesInfo
    sd = Date.today.at_beginning_of_month
    se = Date.today.at_end_of_month
    exist = Journee.select('date').where('date >= ? and date <= ?', sd.to_s(:db), se.to_s(:db) )
        
    existD = exist.map() {|m| m.date }
   return (sd..se).to_a - existD, existD
  end
  
end
