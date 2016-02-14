# coding: utf-8
class Mesure < ActiveRecord::Base
  # Liste des indicateurs mesures
  Indicateurs = %w(Température_eau Température_air pH Limpidité Désinfectant_total Désinfectant_résiduel Personnes Chloramines Alcalinité Turbidité Coliformes)
  
  # Les indicateurs mesurés trois fois par jour et leur heure symbolique de mesure
  Indicateurs3X = %w(Température_eau Température_air pH Limpidité)
  
  # Indicateurs mesurés plusieurs fois par jour.
  IndicateursH = %w(Personnes Désinfectant_résiduel Désinfectant_total Chloramines)
  Heures = %w(6:45 7:00 7:30 8:00 8:30 9:00 9:30 10:00 10:30 11:00 11:30 12:00 12:30 13:00 13:30 14:00 14:30 15:00 15:30 16:00 16:30 17:00 17:30 18:00 18:30 19:00 19:30 20:00 20:30 21:00 21:30)
  
  # Indicateurs non mesurees a la piscine
  IndicateursLab = %w(Chloramines Alcalinité Turbidité Coliformes)
  
  # Liste des plages de respect des normes pour chaque indicateur
  #  "indicateur", "unite de mesure", "min regl", "max regl", 
  IndicateursGraphData = [
    ["Température_eau", "degC"],
    ["Température_air", "degC"],
    ["pH", "", 7.2, 7.8 ],
    ["Limpidité", ""],
    ["Chloramines", "mg/l", 1],
    ["Personnes", ""],
    ["Désinfectant_résiduel", "mg/l", 0.8, 3.0],
    ["Désinfectant_total", "mg/l"],
    ["Alcalinité", "mg/l CaCo3", 60, 150],
    ["Turbidité", "UTN", 1],
    ["Coliformes", "UFC/100ml", 1]
  ]
  
  # attr_accessible :journee, :indicateur, :temps, :valeur, :user_id
  
  belongs_to :journee

  # Trois champs:
  #   indicateur - un de Indicateur
  #   heure - l'heure de collecte
  #   valeur - valeur de la mesure
  #
  # Il y a aussi le lien vers la journee (journee_id)
  
  validates_presence_of :indicateur, :valeur
  validates_presence_of :temps
  validates_numericality_of :valeur
  validates_inclusion_of :indicateur, :in => Indicateurs
  
  # Retourner l'heure seulement
  def to_heure_s
    self.temps.localtime.strftime('%k:%M').lstrip
  end
  
  # Une method pour permettre d'ordonner les valeurs. Regroup par indicateur
  # et ensuite par Heures
  def <=>(other)
    return Indicateurs.index(self.indicateur) <=> Indicateurs.index(other.indicateur) if self.indicateur != other.indicateur
    return self.temps <=> other.temps
  end
  
  def auteur
    u = User.find_by_id(self.user_id)
    u.nil? ? "auteur inconnu" : u.nom
  end
  
  def inRange?
    gi = Mesure::IndicateursGraphData.assoc(self.indicateur)
    if gi.size() < 3
      return true
    elsif gi.size() == 3
      return self.valeur >= 0 && self.valeur < gi[2]
    else
      return self.valeur >= gi[2] && self.valeur < gi[3]
    end
  end
end
