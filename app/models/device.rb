# frozen_string_literal: true

class Device < ApplicationRecord
  has_many :measurements
  # has_and_belongs_to_many :maps

  validates :manufacturer, presence: true
  validates :model, presence: true, uniqueness: { scope: :manufacturer }
  validates :sensor, presence: true

  def self.filter(query)
    where("lower(manufacturer) LIKE :query
           OR lower(model) LIKE :query
           OR lower(sensor) LIKE :query", query: "%#{query.downcase}%")
  end

  def serializable_hash(options)
    options ||= {}
    super(options.merge(only: %i(
      id manufacturer model sensor
    )))
  end

  def self.get_or_create(dev_params) # rubocop:disable Metrics/MethodLength
    device = new(dev_params)
    if device.valid?
      device.save
    else
      d = where(
        manufacturer: device.manufacturer,
        model: device.model,
        sensor: device.sensor
      )
      device = d.first unless d.empty?
    end
    device
  end

  def identifier
    "#{manufacturer} - #{model} (#{sensor})"
  end

  alias_method :name, :identifier
end
