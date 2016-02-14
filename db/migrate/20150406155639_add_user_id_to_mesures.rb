class AddUserIdToMesures < ActiveRecord::Migration
  def change
    add_column :mesures, :user_id, :integer, :default => 0
  end
end
