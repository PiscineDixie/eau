class AddIndexToEmployes < ActiveRecord::Migration[5.0]
  def change
    add_index(:users, :courriel, unique: true, name: 'users_unique_courriel')
  end
end
