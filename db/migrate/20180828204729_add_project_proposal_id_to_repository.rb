class AddProjectProposalIdToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :project_proposal_id, :integer
  end
end
