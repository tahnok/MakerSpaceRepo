class RemoveTrainingSessionIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :training_session_id, :string
  end
end
