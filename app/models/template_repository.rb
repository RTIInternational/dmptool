# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories_templates
#
#  template_id      :integer
#  repository_id    :integer
#
# Indexes
#
# Foreign Keys
#
#  fk_rails_...  (template_id => template.id)
#  fk_rails_...  (repository_id => respository.id)

# Object that represents a DMP template and repository relationship
class TemplateRepository < ApplicationRecord
  # ================
  # = Associations =
  # ================
  has_many :templates
  has_many :repositories
  # ===============
  # = Validations =
  # ===============
  validates :template, presence: { message: PRESENCE_MESSAGE }
  validates :repositories, presence: { message: PRESENCE_MESSAGE }
  # ==========
  # = Scopes =
  # ==========

  # Retrieves any repository related to the template
  scope :repo_list, -> { where(template_id: template.id) }
end
