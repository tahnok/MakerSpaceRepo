class Rfid < ApplicationRecord
  belongs_to :user, optional: true
  scope :recent_unset, -> { where(user: nil).order("updated_at desc") }
  validates :card_number,
            presence: {
              message: "Card number is required."
            },
            uniqueness: {
              message: "Card number is already in use."
            }
end
