# frozen_string_literal: true

# == Schema Information
#
# Table name: prefs
#
#  id       :integer          not null, primary key
#  settings :text(65535)
#  user_id  :integer
#

# Object that represents a User's email preferences
class Pref < ApplicationRecord
  ##
  # Serialize prefs to JSON
  serialize :settings, JSON

  # ================
  # = Associations =
  # ================
  belongs_to :user

  # ===============
  # = Validations =
  # ===============

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :settings, presence: { message: PRESENCE_MESSAGE }

  # The default preferences
  #
  # Returns Hash
  def self.default_settings
    Rails.configuration.x.application.preferences
  end
end
