# frozen_string_literal: true

class UpdatingIdentityOfOldUsers < ActiveRecord::Migration[5.0]
  def change
    User
      .where("created_at < ?", 1.month.ago)
      .where(identity: nil)
      .update_all(identity: "unknown")
  end
end
