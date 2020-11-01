# frozen_string_literal: true

class ProficientProject < ApplicationRecord
  include Filterable
  has_and_belongs_to_many :users
  belongs_to :training
  belongs_to :badge_template
  has_many :photos,                     dependent: :destroy
  has_many :repo_files,                 dependent: :destroy
  has_many :videos,                     dependent: :destroy
  has_many :project_requirements,       dependent: :destroy
  has_many :required_projects, through: :project_requirements
  has_many :inverse_project_requirements, class_name: 'ProjectRequirement', foreign_key: 'required_project_id'
  has_many :inverse_required_projects, through: :inverse_project_requirements, source: :proficient_project
  has_many :cc_moneys,                  dependent: :destroy
  has_many :order_items,                dependent: :destroy
  has_many :badge_requirements,         dependent: :destroy
  has_many :project_kits,               dependent: :destroy
  has_one :drop_off_location

  validates :title, presence: { message: 'A title is required.' }, uniqueness: { message: 'Title already exists' }
  before_save :capitalize_title

  scope :filter_by_level, ->(level) { where(level: level) }

  def capitalize_title
    self.title = title.capitalize
  end

  def self.filter_by_attribute(attribute, value)
    if attribute == 'level'
      filter_by_level(value)
    elsif attribute == 'category'
      joins(:training).where(trainings: { name: value })
    elsif attribute == 'search'
      where("LOWER(title) like LOWER(?) OR
                 LOWER(level) like LOWER(?) OR
                 LOWER(description) like LOWER(?)", "%#{value}%", "%#{value}%", "%#{value}%")
    elsif attribute == 'price'
      bool = true if value.eql?('Paid')
      bool = false if value.eql?('Free')
      where(proficient: bool)
    else
      self
    end
  end

  def delete_all_badge_requirements
    badge_requirements.destroy_all
  end

  def create_badge_requirements(badge_requirements_id)
    badge_requirements_id.each do |requirement_id|
      badge_template = BadgeTemplate.find_by(id: requirement_id)
      badge_requirements.create(badge_template: badge_template) if badge_template
    end
  end

  def extract_urls
    URI.extract(self.description)
  end

  def extract_valid_urls
    self.extract_urls.uniq.select{ |url| url.include?("wiki.makerepo.com") }
  end

  def self.training_status(training_id, user_id)
    pp_missing = ProficientProject.where.not(id: User.find(user_id).order_items.awarded.pluck(:proficient_project_id)).where(training_id: training_id)
    levels_missing = pp_missing.pluck(:level)
    if levels_missing.include?("Beginner")
      "Beginner"
    elsif levels_missing.include?("Intermediate")
      "Intermediate"
    elsif levels_missing.include?("Advanced")
      "Advanced"
    else
      "Master"
    end
  end
end
