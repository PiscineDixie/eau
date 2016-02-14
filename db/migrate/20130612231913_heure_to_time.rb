# coding: utf-8
class HeureToTime < ActiveRecord::Migration
  def up
    add_column :mesures, :temps, :datetime
    Mesure.reset_column_information
    Mesure.all.each do |m|
      case m.heure
      when 'Ouverture'
        hs = '8:00'
      when 'Mi-journée'
        hs = '12:00'
      when 'Fermeture'
        hs = '21:00'
      else
        hs = m.heure
      end 
      t = Time.parse(hs, m.journee.date)
    m.update_attributes!({:temps => t}, :without_protection => true)
    end
    remove_column :mesures, :heure
  end

  def down
    add_column :mesures, :heure, :string
    Mesure.reset_column_information
    Mesure.all.each do |m|
      m.update_attributes!({:heure => m.to_heure_s}, :without_protection => true)
    end
    drop_column :mesures, :temps
  end
end
