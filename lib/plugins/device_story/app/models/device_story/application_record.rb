# frozen_string_literal: true

module DeviceStory
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
