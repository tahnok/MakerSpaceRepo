class RemoveActiveFromVolunteerTask < ActiveRecord::Migration
  def change
    remove_column :volunteer_tasks, :active
  end
end
