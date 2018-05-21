class AddUserIdToMesures < ActiveRecord::Migration[5.0]
  def change
    add_column :mesures, :user_id, :integer, :default => 0
  end
end
