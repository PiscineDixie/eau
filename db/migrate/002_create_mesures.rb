# coding: utf-8
class CreateMesures < ActiveRecord::Migration[5.0]
  def self.up
    create_table :mesures do |t|
      t.references :journee
      t.string  :indicateur, :null => false
      t.string  :heure, :null => false
      t.decimal :valeur, :null => false, :precision => 8, :scale =>3

      t.timestamps
    end
    
  end

  def self.down
    drop_table :mesures
  end
end
