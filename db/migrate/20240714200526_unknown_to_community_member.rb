class UnknownToCommunityMember < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      # find these users
      user_ids = [62, 267, 315, 467, 624]
      direction.up do
        User.where(id: user_ids).update_all(identity: "community_member")
      end
      direction.down do
        User.where(id: user_ids).update_all(identity: "unknown")
      end
    end
  end
end
