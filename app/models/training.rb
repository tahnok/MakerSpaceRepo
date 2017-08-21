class Training < ActiveRecord::Base
  belongs_to :space
  has_many :training_session, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :space_id, presence: true
end
