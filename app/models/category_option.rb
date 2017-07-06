class CategoryOption < ActiveRecord::Base
  belongs_to :admin
  validates :name, presence: true, uniqueness: true
  scope :show_options, -> { order("lower(name) ASC").all }
end
