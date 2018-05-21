class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :courriel
      t.string :nom
      t.string :roles
      t.timestamps
    end
    add_index :users, :courriel
  end
  
  
end
