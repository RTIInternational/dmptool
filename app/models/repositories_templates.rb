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

# Object that represents a DMP template
# rubocop:disable Metrics/ClassLength

class RepositoriesTemplates < ApplicationRecord
    has_many :templates
    has_many :repositories
end