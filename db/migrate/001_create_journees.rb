# coding: utf-8
class CreateJournees < ActiveRecord::Migration
  def self.up
    create_table :journees do |t|
      t.date :date, :null => false

      t.timestamps
    end
    add_index :journees, :date, :unique => true
end

  def self.down
    remove_index journees, :date
    drop_table :journees
  end
end
