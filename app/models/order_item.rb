# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :proficient_project, optional: true
  belongs_to :order, optional: true
  validates :quantity,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validate :product_present
  validate :order_present
  before_save :finalize
  scope :completed_order,
        -> {
          joins(order: :order_status).where(
            order_statuses: {
              name: "Completed"
            }
          )
        }
  scope :in_progress, -> { where(status: "In progress") }
  scope :awarded, -> { where(status: "Awarded") }
  scope :waiting_for_approval, -> { where(status: "Waiting for approval") }

  def unit_price
    persisted? ? self[:unit_price] : proficient_project.cc
  end

  def total_price
    unit_price * quantity
  end

  private

  def product_present
    errors.add(:proficient_project, "is not valid") if proficient_project.nil?
  end

  def order_present
    errors.add(:order, "is not a valid order.") if order.nil?
  end

  def finalize
    self[:unit_price] = unit_price
    self[:total_price] = quantity * self[:unit_price]
  end
end
