# frozen_string_literal: true

class EditCertifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :certifications, :trainer_id, :string
    remove_column :certifications, :training, :string
    add_column :certifications, :training_session_id, :integer
  end
end
