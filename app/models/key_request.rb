class KeyRequest < ApplicationRecord
  belongs_to :user, class_name: "User", optional: true
  belongs_to :supervisor, class_name: "User", optional: true
  belongs_to :space, optional: true
  has_many_attached :files, dependent: :destroy

  enum :status, %i[waiting_for_approval approved rejected], prefix: false

  validates :user, presence: { message: "A user is required" }
  validates :supervisor, presence: { message: "A supervisor is required" }
  validates :space, presence: { message: "A space is required" }

  validates :phone_number,
            :emergency_contact_phone_number,
            format: {
              with: /\A\d{10}\z/,
              message: "should be a 10-digit number"
            }

  validates :student_number,
            :emergency_contact,
            presence: {
              message: "student number and emergency contact is required"
            }

  validates :files,
            file_content_type: {
              allow: %w[application/pdf],
              if: -> { files.attached? }
            }
end
