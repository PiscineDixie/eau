# coding: utf-8
#
# Classe qui contient la representation du registre pour une annee
#
# Les donnees de l'annee sont dans un 
class Registre
  attr_reader :data, :header # Un array d'array
  
  # Creer le data pour le rapport. Une ligne par indicateur par jour
  def initialize(annee)
    initHeader
    @data = Array.new
    
    journees = Journee.
       where("date >= :min and date <= :max", { :min => annee+'-01-01', :max => annee+'12-31'}).
       order(:date)
    
    journees.each do |j|
      @data << [j.date.to_formatted_s(:db)]
      iv = j.mesuresSorted.group_by { |m| m.indicateur }
      iv.each do |indic, ms|
        @data << ['', indic.tr('_', ' ')]
        ms.each do | m |
          @data.last[colIdx(m)] = m.valeur
        end
      end
    end
  end
    
  # Retourner l'entete pour une ligne du rapport
  def initHeader
    hdr = Array.new
    hdr << 'Date' << 'Indicateur'
    hrs = Mesure::Heures;
    hdr << hrs.sort_by { |a| [a.length, a]}
    hdr.flatten!
    @header = hdr
  end
  
  # Retourner l'index de la colonne dans le rapport
  def colIdx(mesure)
    idx = @header.index(mesure.to_heure_s)
    Rails.logger.info("Could not find the index for #{mesure.to_heure_s}")
    return idx
  end
  
end