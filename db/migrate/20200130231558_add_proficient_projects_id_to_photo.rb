class AddProficientProjectsIdToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :proficient_project_id, :integer
  end
end
