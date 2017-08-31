class Space < ActiveRecord::Base
  has_many :pi_readers
  has_many :lab_sessions, dependent: :destroy
  has_many :users, through: :lab_sessions
  has_many :trainings, dependent: :destroy
  has_many :training_sessions, through: :trainings
  has_many :certifications, through: :training_sessions
  validates :name,  presence: { message: "A name is required for the space"}, uniqueness: { message: "Space already exists"}

  def signed_in_users
    return self.lab_sessions.where("sign_out_time > ?", Time.now).map(&:user)
  end

end
