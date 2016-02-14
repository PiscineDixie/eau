# coding: utf-8
# Classe pour les donnees permanente et annuelles d'un employe
#
class Employe < ActiveRecord::Base
      
  establish_connection("#{Rails.env}_paie".to_sym)
  
  def actif?
    return self.etat == 'actif'
  end
end
