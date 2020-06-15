# frozen_string_literal: true

class ChangeBadgeIdFromBadgeTemplate < ActiveRecord::Migration[5.0]
  def change
    rename_column :badge_templates, :badge_id, :acclaim_template_id
  end
end
